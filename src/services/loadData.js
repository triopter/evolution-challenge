import {
  objectComparator,
} from './comparators'

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

  setRank = (rank, eligibility) => {
    this.rank = rank
    this.eligibility = eligibility
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

    this.computeRanks()

    return Object.values(this.teams)
  }

  addMatchToTeam = (name, goalsFor, goalsAgainst) => {
    let team = this.teams[name] = this.teams[name] || new Team(name)
    team.addMatch(goalsFor, goalsAgainst)
  }

  computeRanks = () => {
    // A little more complex than otherwise because it allows for ties
    let currentRank = 0
    let currentPoints = Number.MAX_SAFE_INTEGER
    let currentGoalDiff = Number.MAX_SAFE_INTEGER
    let currentGoals = Number.MAX_SAFE_INTEGER
    let teamCount = Object.keys(this.teams).length

    Object.values(this.teams)
      .sort((teamA, teamB) => objectComparator(teamA, teamB, ['points', 'goalDifference', 'goals'], -1))
      .forEach((team, index) => {
        if (team.points < currentPoints
            || team.goalDifference < currentGoalDiff
            || team.goals < currentGoals ) {
          currentPoints = team.points
          currentGoalDiff = team.goalDifference
          currentGoals = team.goals
          currentRank = index + 1
        }

        // NOTE: this does not account for the possibility of ties on the edges of eligibility tiers
        // Or for leagues of < 9 teams
        // Fortunately, our example data set doesn't have these issues
        // For a production app, this would require researching or consulting a product
        // manager to determine how ties are handled w.r.t. eligibility.
        let eligibility = null
        if (currentRank <= 4) {
          eligibility = 'uefa'
        }
        else if (currentRank <= 6) {
          eligibility = 'europa'
        }
        else if (currentRank >= (teamCount - 3)) {
          eligibility = 'relegated'
        }

        this.teams[team.name].setRank(currentRank, eligibility)
      })
  }
}

export const dataFromFilename = (filename) => {
  return fetch(filename).then(response => {
    return response.json()
  })
}

export default DataLoader