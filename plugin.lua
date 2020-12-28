local function not_has(table, val)
    for _, value in pairs(table) do
        if value == val then
            return false
        end
    end

    return true
end

--this code is just Keep Still lol
function draw()
    imgui.Begin("Float")

    state.IsWindowHovered = imgui.IsWindowHovered()

    --I'll implement some way to input numbers if/when I feel like it
    local INITIAL_OFFSET = state.GetValue("INITIAL_OFFSET") or 0
    local SOME_NUMBER = state.GetValue("SOME_NUMBER") or 1 --What SV to normalize to
    local INCREMENT = 2^-6 --powers of 2 are your friend, small number also bad, but small number funny and make playfield go teleport, numbers smaller than this may cause rounding errors
    local AVG_SV = state.GetValue("AVG_SV") or 1
    local SV_SLOPE = state.GetValue("SV_SLOPE") or 0

    local PLACE_END_SV = state.GetValue("PLACE_END_SV") or false

    local lastoffset = state.GetValue("lastoffset") or -1
    local lastsv = state.GetValue("lastsv") or -1
    local nextoffset = state.GetValue("nextoffset") or -1
    local nextsv = state.GetValue("nextsv") or -1

    _, INITIAL_OFFSET = imgui.InputFloat("Offset", INITIAL_OFFSET, 1)
    _, SOME_NUMBER = imgui.InputFloat("Slope", SOME_NUMBER, 1)
    _, AVG_SV = imgui.InputFloat("Initial SV", AVG_SV, .05)
    _, SV_SLOPE = imgui.InputFloat("SV Slope", SV_SLOPE, .01)

    _, PLACE_END_SV = imgui.Checkbox("Return to Normal at End?", PLACE_END_SV)

    if imgui.Button("click me") then
        local notes = state.SelectedHitObjects --should check to see if there are enough objects selected but I don't care

        --maybe jank way of removing redundant notes idk
        local starttimes = {}

        for _,note in pairs(notes) do
            if not_has(starttimes, note.StartTime) then
                table.insert(starttimes, note.StartTime)
            end
        end

        local svs = {}

        for i,starttime in pairs(starttimes) do
            table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, (INITIAL_OFFSET / INCREMENT + SOME_NUMBER * (i-1) / INCREMENT) * (AVG_SV + SV_SLOPE * (i-1))))
            if i == #starttimes then
                if PLACE_END_SV then
                    table.insert(svs, utils.CreateScrollVelocity(starttime, 1))
                else
                    lastoffset = INITIAL_OFFSET + SOME_NUMBER * (i-1)
                    lastsv = AVG_SV + SV_SLOPE * (i-1)
                    nextoffset = INITIAL_OFFSET + SOME_NUMBER * i
                    nextsv = AVG_SV + SV_SLOPE * i
                    table.insert(svs, utils.CreateScrollVelocity(starttime, -((INITIAL_OFFSET / INCREMENT + SOME_NUMBER * (i-1)  / INCREMENT) * (AVG_SV + SV_SLOPE * (i-1))) + 2))
                    table.insert(svs, utils.CreateScrollVelocity(starttime + INCREMENT, AVG_SV + SV_SLOPE * (i-1)))
                end
            else
                table.insert(svs, utils.CreateScrollVelocity(starttime, -((INITIAL_OFFSET / INCREMENT + SOME_NUMBER * (i-1)  / INCREMENT) * (AVG_SV + SV_SLOPE * (i-1))) + 2))
                table.insert(svs, utils.CreateScrollVelocity(starttime + INCREMENT, AVG_SV + SV_SLOPE * (i-1)))
            end
        end

        actions.PlaceScrollVelocityBatch(svs)
    end

    if lastoffset >= 0 then
        imgui.TextWrapped("Last Offset: " .. lastoffset)
        imgui.TextWrapped("Last SV: " .. lastsv)
        imgui.TextWrapped("Next Offset: " .. nextoffset)
        imgui.TextWrapped("Next SV: " .. nextsv)
    end

    state.SetValue("SOME_NUMBER", SOME_NUMBER)
    state.SetValue("AVG_SV", AVG_SV)
    state.SetValue("INITIAL_OFFSET", INITIAL_OFFSET)
    state.SetValue("SV_SLOPE", SV_SLOPE)

    state.SetValue("PLACE_END_SV", PLACE_END_SV)

    state.SetValue("lastoffset", lastoffset)
    state.SetValue("lastsv", lastsv)
    state.SetValue("nextoffset", nextoffset)
    state.SetValue("nextsv", nextsv)

    imgui.End()
end
