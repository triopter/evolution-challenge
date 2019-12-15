class Team {
  constructor (name) {
    this.name = name
    this.wins = 0
    this.draws = 0
    this.losses = 0
    this.goalsFor = 0
    this.goalsAgainst = 0
    this.goalDifference = 0
    this.points = 0
    this.rank = null
    this.eligibility = ''
  }

  addMatch = (goalsFor, goalsAgainst) => {
    this.goalsFor += goalsFor
    this.goalsAgainst += goalsAgainst

    if (goalsFor === goalsAgainst) {
      this.draws += 1
    }
    else if (goalsFor > goalsAgainst) {
      this.wins += 1
    }
    else {
      this.losses += 1
    }

    this.updateGoalDifference()
    this.updatePoints()
  }

  updateGoalDifference = () => {
    this.goalDifference = this.goalsFor - this.goalsAgainst
  }

  updatePoints = () => {
    this.points = (3 * this.wins) + this.draws
  }
}


class DataLoader {
  constructor (data) {
    this.data = data
    this.teams = {}
  }

  import = () => {
    // NOTE: assuming for now that the data is well-formed in the expected format
    // For a production app, would need better error handling
    this.data.rounds.forEach(round => {
      round.matches.forEach(match => {
        // Team 1 version
        this.addMatchToTeam(match.team1.name, match.score1, match.score2)

        // Team 2 version
        this.addMatchToTeam(match.team2.name, match.score2, match.score1)
      })
    })

    return Object.values(this.teams)
  }

  addMatchToTeam = (name, goalsFor, goalsAgainst) => {
    let team = this.teams[name] = this.teams[name] || new Team(name)
    team.addMatch(goalsFor, goalsAgainst)
  }
}

export const dataFromFilename = (filename) => {
  return fetch(filename).then(response => {
    return response.json()
  })
}

export default DataLoader