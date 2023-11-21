load("render.star", "render")
load("http.star", "http")
load("encoding/base64.star", "base64")

NBA_LEADERS_URL = "https://stats.nba.com/stats/leagueleaders?ActiveFlag=&LeagueID=00&PerMode=PerGame&Scope=S&Season=2023-24&SeasonType=Regular+Season&StatCategory="

NBA_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAZCAYAAAAIcL+IAAAAAXNSR0IArs4c6QAAA
NNJREFUOE9jZLDf9p8BDdT7XAWLOLRMh8sw0l4hNmtB9sOthilAdi6GG7EpgmmAKW
as7+7G8DV6KIAU41QIkjxQkwkPJuIVMjhs+1/vDQlgdHeB+CBTCVpNskJ4OOIKQ5h
n8CpEDyJ4zBQ432Lg5/yN4akTuTFgMZTUg+4EvMkMl2K86RE58VKmEGQSK/M/hirP
6wxMv/8w2HXOZmD8/+0bRuph9DzA8H+7A0PD1KmIRIFNISyMQBpAngPHNUghzASMQ
CZWIUgjyHqwidiyK7LJMKsBEZKc8RllF3QAAAAASUVORK5CYII=
""")

def main():
    # ranks list with player columns holding their name, team, and stat
    ranks = []

    # populates stats
    for i in range(15):
        stat_name, stat_url, stat_index, rank = set_stat_names(i)
        stat_req = http.get(NBA_LEADERS_URL + stat_url)
        stats = stat_req.json()["resultSet"]["rowSet"]
        full_name = stats[rank][2].split()
        name = full_name[0][0] + ". " + full_name[-1]
        player = dict(
            name = name,
            team = stats[rank][4],
            stat_name = stat_name,
            stat = stats[rank][stat_index]
        )
        ranks.append(player_column(player, rank))

    # output to tidbyt
    return render.Root(
        delay = 1000,
        child = render.Row(
            children=[
                render.Animation(
                    children = ranks
                )
            ],
        )
    )

def player_column(player, rank):
    return render.Column(
        children=[
            render.Stack(
                children=[
                    render.Box(
                        width=65, 
                        height=8, 
                        color="#424242",
                    ),
                    render.Row(
                        expanded=True,
                        main_align="space_between",
                        cross_align="center",
                        children=[
                            render.Text(" NBA", color="#ff5c5c"),
                            render.Text(player['stat_name'] + " Ranks", color="#5e7eff"),
                        ]
                    )
                ]
            ),
            render.Row(
                expanded=True,
                main_align="space_between",
                cross_align="center",
                children=[
                    render.Text(" " + str(1 + rank) + ") ", color="#fce060"),
                    render.Text(player['name']),
                ]
            ),
            render.Row(
                expanded=True,
                main_align="end",
                cross_align="center",
                children=[
                    render.Text(player['team']),
                ]
            ),
            render.Row(
                expanded=True,
                main_align="end",
                cross_align="center",
                children=[
                    render.Text(str(player['stat']) + " " + player['stat_name']),
                ]
            )
        ]
    )

def set_stat_names(i):
    stat_name = ""
    stat_url = ""
    stat_index = 0
    rank = 0
    if i < 3:
        stat_name = "PPG"
        stat_url = "PTS"
        stat_index = -2
        rank = i
    elif i < 6:
        stat_name = "RPG"
        stat_url = "REB"
        stat_index = -7
        rank = i - 3
    elif i < 9:
        stat_name = "APG"
        stat_url = "AST"
        stat_index = -6
        rank = i - 6
    elif i < 12:
        stat_name = "SPG"
        stat_url = "STL"
        stat_index = -5
        rank = i - 9
    else:
        stat_name = "BPG"
        stat_url = "BLK"
        stat_index = -4
        rank = i - 12
    return stat_name, stat_url, stat_index, rank