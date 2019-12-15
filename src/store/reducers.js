import {
  LOAD_TEAMS,
  SORT_TEAMS,
} from './types'

const initialState = {
  teams: [],
  sortColumn: 'rank',
  sortDirection: 'ASC',
}

const reducers = (state = initialState, action) => {
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
    default: {
      return state
    }
  }
}

export default reducers;

