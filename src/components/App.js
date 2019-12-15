import React, { Component } from 'react'
import { connect } from 'react-redux'

import Table from 'components/Table'

// Note that in a more complex app we might want to memo-ize this
const mapStateToProps = (state) => ({
  teams: state.teams
})

class App extends Component {
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
          columns={ this.columns } />
      </div>
    )
  }
}

export default connect(mapStateToProps)(App);
