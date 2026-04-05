local NasaHorizons = {}

local socket = require("socket")

function NasaHorizons.request()
    local handle = io.popen("curl \"https://ssd.jpl.nasa.gov/api/horizons.api?format=text&COMMAND='499'&OBJ_DATA='YES'&MAKE_EPHEM='YES'&EPHEM_TYPE='OBSERVER'&CENTER='500@399'&START_TIME='2026-01-01'&STOP_TIME='2026-01-02'&STEP_SIZE='1%20d'&QUANTITIES='1,9,20,23,24,29'\"")
    local result = handle:read("*a")
    handle:close()

    return result
end

return NasaHorizons