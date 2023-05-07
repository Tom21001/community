"""
Applet: TransLink RTTI
Summary: Shows Vancouver Next Bus
Description: Shows the next 2 buses of any Bus stop in Vancouver which have a Stop ID
Author: Tom21001
"""

load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")

default_Stop = "50913"
default_Route = "099"
default_color = "#8C1713"
result_0 = "5m"
result_1 = "20m"

def main(config):
    Key = config.str("Api_Key") or ""
    Stop = config.str("Stop_Id") or default_Stop
    Route = config.str("Route_No") or default_Route
    ggcolor = config.str("bus_color") or default_color
    text_color = config.str("bus_text_color") or "#FFFFFF"
    result_dest = ""

    if Key == "" or Key == None:
        print = "Please provid your own API key"
    else:
        result_time, result_dest = get_api(Key, Stop, Route)
        print = "Next Bus: " + result_time

    return render.Root(
        child = render.Column(
            children = [
                render.Box(
                    # Bus service number in red box
                    width = 16,
                    height = 8,
                    padding = 0,
                    color = ggcolor,
                    child = render.Text(str(Route), color = text_color),
                ),
                render.Text(
                    result_dest,
                    color = text_color,
                ),
                render.Marquee(
                    # Marquee showing times of next buses for given service
                    width = 63,
                    child = render.Text(print),
                ),
            ],
        ),
    )

def get_api(Api_Key, Stop_Id, Route_No):
    translink_URL = "https://api.translink.ca/rttiapi/v1/stops/" + str(Stop_Id) + "/estimates?apikey=" + str(Api_Key) + "&count=3&timeframe=120&routeNo=" + str(Route_No)
    rep = http.get(
        translink_URL,
        headers = {"accept": "application/JSON"},
    )

    if rep.status_code != 200:
        fail("Translink request failed with status %d", rep.status_code)

    ans_0 = rep.json()[0]["Schedules"][0]["ExpectedCountdown"]
    ans_1 = rep.json()[0]["Schedules"][1]["ExpectedCountdown"]
    dest = str(rep.json()[0]["Schedules"][0]["Destination"])
    result_0 = str(ans_0) + "m"
    result_1 = str(ans_1) + "m"

    if ans_0 > 60:
        result_0 = str(ans_0 // 60) + "h " + str(ans_0 % 60) + "m"

    if ans_1 > 60:
        result_1 = str(ans_1 // 60) + "h " + str(ans_1 % 60) + "m"

    ans = result_0 + " , " + result_1
    return ans, dest

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "Api_Key",
                name = "Your own api key",
                desc = "Search for translink api to get you own API",
                icon = "flag",
            ),
            schema.Text(
                id = "Stop_Id",
                name = "Your bus stop ID",
                desc = "Go to Translink.ca find your stop ID.",
                icon = "signsPost",
            ),
            schema.Text(
                id = "Route_No",
                name = "Your bus needed",
                desc = "To clarify in case of the stop have more than one bus",
                icon = "bus",
            ),
            schema.Color(
                id = "bus_color",
                name = "Bus box color",
                desc = "A custom background color for the bus number plate.",
                icon = "brush",
                default = "#8C1713",
            ),
            schema.Color(
                id = "bus_text_color",
                name = "Bus text color",
                desc = "A custom text color for the bus number plate.",
                icon = "palette",
                default = "#FFFFFF",
            ),
        ],
    )
