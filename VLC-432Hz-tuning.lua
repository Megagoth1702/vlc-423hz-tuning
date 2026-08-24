-- VLC 432 Hz Tuning
-- Retunes material referenced to A=440 Hz down to A=432 Hz by slowing
-- playback to 432/440 while disabling VLC's pitch-preserving time stretch.

local EXTENSION_VERSION = "1.0.0"
-- Keep these precomputed: VLC's extension scanner does not expose the math
-- library while it evaluates the script's top level.
local TARGET_RATE = 0.9818181818181818
local NORMAL_RATE = 1.0
local TARGET_CENTS = -31.76665363342928
local DURATION_CHANGE = 1.851851851851852

local dlg = nil
local current_rate_label = nil
local time_stretch_label = nil
local status_html = nil
local restart_audio_checkbox = nil

local function absolute(value)
    return value < 0 and -value or value
end

function descriptor()
    return {
        title = "432 Hz Tuning",
        version = EXTENSION_VERSION,
        author = "Andrej Schmitt",
        url = "https://www.videolan.org/vlc/",
        shortdesc = "Retune A=440 Hz playback to A=432 Hz",
        description = "Sets playback rate to 432/440 and disables pitch-preserving audio time stretching.",
        capabilities = { "menu" }
    }
end

local function html_escape(value)
    local text = tostring(value or "")
    text = string.gsub(text, "&", "&amp;")
    text = string.gsub(text, "<", "&lt;")
    text = string.gsub(text, ">", "&gt;")
    return text
end

local function show_status(message, is_error)
    if not status_html then return end

    local heading = is_error and "Could not finish" or "Status"
    status_html:set_text(
        "<p><b>" .. heading .. ":</b> " .. html_escape(message) .. "</p>"
    )
    if dlg then dlg:update() end
end

local function has_vlc4_player_api()
    return type(vlc.player) == "table"
        and type(vlc.player.set_rate) == "function"
        and type(vlc.player.get_rate) == "function"
end

local function get_rate()
    if has_vlc4_player_api() then
        local ok, value = pcall(vlc.player.get_rate)
        if ok and type(value) == "number" then return value end
        return nil
    end

    local playlist = vlc.object.playlist()
    if not playlist then return nil end

    local ok, value = pcall(vlc.var.get, playlist, "rate")
    if ok and type(value) == "number" then return value end
    return nil
end

local function set_rate(rate)
    if has_vlc4_player_api() then
        local ok, err = pcall(vlc.player.set_rate, rate)
        return ok, err
    end

    local playlist = vlc.object.playlist()
    if not playlist then return false, "VLC playlist is not available" end

    local ok, err = pcall(vlc.var.set, playlist, "rate", rate)
    return ok, err
end

local function get_time_stretch()
    local ok, value = pcall(vlc.config.get, "audio-time-stretch")
    if not ok then return nil end
    return value == true or value == 1
end

local function set_time_stretch(enabled)
    local ok, err = pcall(vlc.config.set, "audio-time-stretch", enabled)
    if not ok then return false, err end

    -- Give the current audio output a local value too. The audio filter chain
    -- reads this setting when an audio track is (re)started.
    local aout = vlc.object.aout()
    if aout then
        pcall(vlc.var.create, aout, "audio-time-stretch", enabled)
    end

    return true
end

local function restart_audio_vlc3()
    local input = vlc.object.input()
    if not input then
        return false, "No media is currently playing"
    end

    local ok, track_id = pcall(vlc.var.get, input, "audio-es")
    if not ok or type(track_id) ~= "number" or track_id < 0 then
        return false, "The current media has no selected audio track"
    end

    local disabled, disable_err = pcall(vlc.var.set, input, "audio-es", -1)
    if not disabled then return false, disable_err end

    local restored, restore_err = pcall(vlc.var.set, input, "audio-es", track_id)
    if not restored then return false, restore_err end

    return true
end

local function restart_audio_vlc4()
    if type(vlc.player.get_audio_tracks) ~= "function"
        or type(vlc.player.toggle_audio_track) ~= "function" then
        return false, "This VLC build cannot restart an audio track from Lua"
    end

    local ok, tracks = pcall(vlc.player.get_audio_tracks)
    if not ok or type(tracks) ~= "table" then
        return false, "VLC did not return the current audio tracks"
    end

    local selected_id = nil
    for _, track in ipairs(tracks) do
        if track.selected then
            selected_id = track.id
            break
        end
    end

    if selected_id == nil then
        return false, "The current media has no selected audio track"
    end

    local disabled, disable_err = pcall(vlc.player.toggle_audio_track, selected_id)
    if not disabled then return false, disable_err end

    local restored, restore_err = pcall(vlc.player.toggle_audio_track, selected_id)
    if not restored then return false, restore_err end

    return true
end

local function restart_current_audio()
    if has_vlc4_player_api() then return restart_audio_vlc4() end
    return restart_audio_vlc3()
end

local function refresh_ui()
    local rate = get_rate()
    local stretching = get_time_stretch()

    if current_rate_label then
        if rate then
            local tuned = absolute(rate - TARGET_RATE) < 0.000001
            local suffix = tuned and "  (432 Hz target)" or ""
            current_rate_label:set_text(string.format("Current playback rate: %.12fx%s", rate, suffix))
        else
            current_rate_label:set_text("Current playback rate: unavailable")
        end
    end

    if time_stretch_label then
        if stretching == false then
            time_stretch_label:set_text("Pitch correction: disabled (pitch follows playback rate)")
        elseif stretching == true then
            time_stretch_label:set_text("Pitch correction: enabled (VLC preserves the original pitch)")
        else
            time_stretch_label:set_text("Pitch correction: setting unavailable")
        end
    end

    if dlg then dlg:update() end
end

local function apply_432_tuning()
    local config_ok, config_err = set_time_stretch(false)
    if not config_ok then
        show_status("Pitch correction could not be disabled: " .. tostring(config_err), true)
        refresh_ui()
        return
    end

    local restart_requested = restart_audio_checkbox
        and restart_audio_checkbox:get_checked()
    local audio_restarted = false
    local restart_err = nil

    if restart_requested then
        audio_restarted, restart_err = restart_current_audio()
    end

    local rate_ok, rate_err = set_rate(TARGET_RATE)
    if not rate_ok then
        show_status("Playback rate could not be set: " .. tostring(rate_err), true)
        refresh_ui()
        return
    end

    if restart_requested and not audio_restarted then
        show_status(
            "The 0.981818x rate is set and pitch correction is disabled for new audio, " ..
            "but the current audio could not be refreshed (" .. tostring(restart_err) .. "). " ..
            "Stop and replay the media once to hear the pitch change.",
            true
        )
    elseif restart_requested then
        show_status("432 Hz tuning is active. The audio track was refreshed for live pitch change.", false)
    else
        show_status("The target rate is set. Stop and replay the media once if its pitch is still preserved.", false)
    end

    vlc.msg.info(string.format(
        "432 Hz Tuning applied: rate=%.12f, pitch shift=%.4f cents",
        TARGET_RATE,
        TARGET_CENTS
    ))
    refresh_ui()
end

local function restore_normal_rate()
    local ok, err = set_rate(NORMAL_RATE)
    if ok then
        show_status("Playback rate restored to 1.000000x. The pitch-correction preference was left unchanged.", false)
    else
        show_status("Normal playback rate could not be restored: " .. tostring(err), true)
    end
    refresh_ui()
end

local function enable_pitch_correction()
    local ok, err = set_time_stretch(true)
    if not ok then
        show_status("Pitch correction could not be enabled: " .. tostring(err), true)
        refresh_ui()
        return
    end

    local restarted, restart_err = true, nil
    if restart_audio_checkbox and restart_audio_checkbox:get_checked() then
        restarted, restart_err = restart_current_audio()
    end

    if restarted then
        show_status("VLC pitch correction is enabled again.", false)
    else
        show_status(
            "Pitch correction is enabled for new audio, but the current track could not be refreshed (" ..
            tostring(restart_err) .. "). Stop and replay it once.",
            true
        )
    end
    refresh_ui()
end

local function create_dialog()
    dlg = vlc.dialog("432 Hz Tuning")

    dlg:add_html(
        "<h2>Retune A = 440 Hz to A = 432 Hz</h2>" ..
        "<p>This slows playback slightly and disables VLC's pitch-preserving time stretch, " ..
        "so pitch and tempo move together.</p>",
        1, 1, 4, 1
    )

    dlg:add_html(
        string.format(
            "<p><b>Target rate</b><br>432 / 440 = %.12fx</p>" ..
            "<p><b>Result</b><br>Pitch: %.2f cents<br>Duration: +%.2f%%</p>",
            TARGET_RATE,
            TARGET_CENTS,
            DURATION_CHANGE
        ),
        1, 2, 2, 2
    )

    dlg:add_html(
        "<p><b>Why pitch correction must be off</b><br>" ..
        "VLC's time-stretch filter normally keeps pitch unchanged when speed changes. " ..
        "This extension disables that filter; it does not disable the general-purpose audio resampler.</p>",
        3, 2, 2, 2
    )

    current_rate_label = dlg:add_label("Current playback rate: checking...", 1, 4, 4, 1)
    time_stretch_label = dlg:add_label("Pitch correction: checking...", 1, 5, 4, 1)

    restart_audio_checkbox = dlg:add_check_box(
        "Refresh the current audio track so the pitch change takes effect now",
        true,
        1, 6, 4, 1
    )

    dlg:add_button("Apply 432 Hz tuning", apply_432_tuning, 1, 7, 2, 1)
    dlg:add_button("Restore normal rate", restore_normal_rate, 3, 7, 2, 1)
    dlg:add_button("Enable pitch correction", enable_pitch_correction, 1, 8, 2, 1)
    dlg:add_button("Refresh status", refresh_ui, 3, 8, 2, 1)

    status_html = dlg:add_html(
        "<p><b>Ready.</b> Start playback, then choose <i>Apply 432 Hz tuning</i>.</p>",
        1, 9, 4, 1
    )

    refresh_ui()
    dlg:show()
end

function activate()
    if dlg then dlg:delete() end
    create_dialog()
end

function deactivate()
    if dlg then
        dlg:delete()
        dlg = nil
    end
end

function close()
    vlc.deactivate()
end

function menu()
    return { "Open 432 Hz Tuning" }
end

function trigger_menu(id)
    if id == 1 then
        if dlg then
            dlg:show()
            refresh_ui()
        else
            create_dialog()
        end
    end
end
