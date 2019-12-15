import React, { Component } from 'react'
import { connect } from 'react-redux'

import {
  loadTeamsFromFile,
  setTeamSort,
  loadTeamsFromServer,
  toggleDataMode,
} from 'store/actions'
import {
  sortedTeams,
  getNextRemoteDataState,
} from 'store/selectors'

import Table from 'components/Table'

// Note that in a more complex app we might want to memo-ize this
const mapStateToProps = (state) => ({
  teams: sortedTeams(state.teams,
                      state.sortColumn,
                      state.sortDirection),
  useRemoteData: state.useRemoteData,
})

const mapDispatchToProps = dispatch => ({
  loadTeamsFromFile: (...args) => dispatch(loadTeamsFromFile(...args)),
  setTeamSort: (...args) => dispatch(setTeamSort(...args)),
  loadTeamsFromServer: (...args) => dispatch(loadTeamsFromServer(...args)),
  toggleDataMode: (...args) => dispatch(toggleDataMode(...args)),
})

class App extends Component {
  componentDidMount () {
    this.refreshData(this.props.useRemoteData)
  }

  refreshData = (useRemoteData) => {
    if (useRemoteData) {
      this.props.loadTeamsFromServer(this.props.serverUrl)
    }
    else {
      this.props.loadTeamsFromFile(this.props.dataFileName)
    }
  }

  changeDataMode = () => {
    // need to detect and send this here because the prop won't change until the next tick
    // A more elegant solution might be to subscribe to the data directly in the store
    let nowUseRemote = getNextRemoteDataState(this.props.useRemoteData)
    this.refreshData(nowUseRemote)
    this.props.toggleDataMode()
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
        <p>Loading data {this.props.useRemoteData ? 'from server' : 'in client' }.
          <button onClick={this.changeDataMode}>
            Reload {this.props.useRemoteData ? 'in client' : 'from server'}
          </button>
        </p>
        <Table
          data={ this.props.teams }
          columns={ this.columns }
          sortCallback={ this.props.setTeamSort } />
      </div>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(App);
