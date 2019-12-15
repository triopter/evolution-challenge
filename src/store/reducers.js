import {
  LOAD_TEAMS,
} from './types'

const initialState = {
  teams: [],
}

const reducers = (state = initialState, action) => {
  switch (action.type) {
    case LOAD_TEAMS: {
      return { ...state, teams: [ ...action.payload ] }
    }
    default: {
      return state
    }
  }
}

export default reducers;

