import React, { Component } from 'react'
import { connect } from 'react-redux'

import {
  loadTeamsFromFile,
  setTeamSort,
} from 'store/actions'
import { sortedTeams } from 'store/selectors'

import Table from 'components/Table'

// Note that in a more complex app we might want to memo-ize this
const mapStateToProps = (state) => ({
  teams: sortedTeams(state.teams,
                      state.sortColumn,
                      state.sortDirection),
})

const mapDispatchToProps = dispatch => ({
  loadTeamsFromFile: (...args) => dispatch(loadTeamsFromFile(...args)),
  setTeamSort: (...args) => dispatch(setTeamSort(...args)),
})

class App extends Component {
  componentDidMount () {
    this.props.loadTeamsFromFile(this.props.dataFileName)
  }

  columns = [
    { id: 'rank', name: 'Rank' },
    { id: 'name', name: 'Team' },
    { id: 'wins', name: 'Wins' },
    { id: 'draws', name: 'Draws' },
    { id: 'losses', name: 'Losses' },
    { id: 'goalsFor', name: 'Goals For' },
    { id: 'goalsAgainst', name: 'Goals Against' },
    { id: 'goalDifference', name: 'Goal Difference' },
    { id: 'points', name: 'Points' },
  ]

  render () {
    return (
      <div>
        <Table
          data={ this.props.teams }
          columns={ this.columns }
          sortCallback={ this.props.setTeamSort } />
      </div>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(App);
