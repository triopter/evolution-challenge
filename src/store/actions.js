import {
  LOAD_TEAMS,
  SORT_TEAMS,
} from './types'

import DataLoader, {
  dataFromFilename
} from '../services/loadData'

export const loadTeamsFromFile = (filename) => (dispatch) => {
  return dataFromFilename(filename).then(data => dispatch(loadTeamsFromData(data)))
}

export const loadTeamsFromData = (data) => (dispatch) => {
  let teamData = new DataLoader(data).import()
  return dispatch(loadTeams(teamData))
}

export const loadTeams = (data) => ({
  type: LOAD_TEAMS,
  payload: data,
})

export const setTeamSort = (sortColumn, sortDirection) => (dispatch) => {
  dispatch({
    type: SORT_TEAMS,
    sortColumn: sortColumn,
    sortDirection: sortDirection,
  })
}