import {
  objectComparator,
} from 'services/comparators'

export const sortedTeams = (teams, sortColumn, sortDirection) => {
  // destructure so we have a fresh array, otherwise React won't recognize the change
  // and trigger a re-render
  return [...teams].sort((teamA, teamB) => {
    return objectComparator(teamA,
                            teamB,
                            [sortColumn],
                            (sortDirection === 'DESC' ? -1 : 1))
  })
}