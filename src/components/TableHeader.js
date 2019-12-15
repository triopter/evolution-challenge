import React from 'react'
import { connect } from 'react-redux'

const mapStateToProps = (state) => ({
  sortColumn: state.sortColumn,
  sortDirection: state.sortDirection,
})

const TableHeader = (props) => {
  const isSortColumn = (colName) => {
    return colName === props.sortColumn
  }

  const sortDirClass = (direction) => {
    return direction === 'DESC' ? 'desc' : 'asc'
  }

  const getClasses = (colName) => {
    let classes = []
    if (isSortColumn(colName)) {
      classes.push('sorted')
      classes.push(sortDirClass(props.sortDirection))
    }
    classes.push(`next-sort-${sortDirClass(nextSortDir(colName))}`)
    return classes
  }

  const nextSortDir = (colName) => {
    if (isSortColumn(colName)) {
      return props.sortDirection === 'DESC' ? 'ASC' : 'DESC'
    }
    return 'ASC'
  }

  return (
    <tr>
      {
        props.columns.map((column) => {
          return <th key={ column.id }
            className={ getClasses(column.id).join(' ') }
            onClick={ () => props.sortCallback(column.id, nextSortDir(column.id)) }>
              { column.name }
          </th>
        })
      }
    </tr>
  )
}

export default connect(mapStateToProps)(TableHeader)