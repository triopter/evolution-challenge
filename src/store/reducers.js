import {
  LOAD_TEAMS,
  SORT_TEAMS,
  TOGGLE_MODE,
} from './types'

import {
  getNextRemoteDataState,
} from './selectors'

const initialState = {
  teams: [],
  sortColumn: 'rank',
  sortDirection: 'ASC',
  useRemoteData: false,
}

const teams = (state = initialState, action) => {
  switch (action.type) {
    case LOAD_TEAMS: {
      return { ...state, teams: [ ...action.payload ] }
    }
    case SORT_TEAMS: {
      return {
        ...state,
        sortColumn: action.sortColumn,
        sortDirection: action.sortDirection
      }
    }
    case TOGGLE_MODE: {
      return {
        ...state,
        useRemoteData: getNextRemoteDataState(state.useRemoteData),
      }
    }
    default: {
      return state
    }
  }

}

export default teams;

