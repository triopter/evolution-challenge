import React from 'react'
import TableHeader from './TableHeader'
import TableRow from './TableRow'

const Table = (props) => {
  return (
    <table>
      <thead>
        <TableHeader columns={ props.columns } />
      </thead>
      <tbody>
        { props.data.map((team) => {
          return <TableRow team={ team } key={ team.name } columns={ props.columns } />
        }) }
      </tbody>
    </table>
  )
}

export default Table