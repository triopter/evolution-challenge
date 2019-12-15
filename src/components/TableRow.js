import React from 'react'

const TableRow = (props) => {
  return (
    <tr className={ props.team.eligibility }>
      {
        props.columns.map((column) => {
          return <td key={ `${column.id}.${props.team.name}` }>
            { props.team[column.id] }
          </td>
        })
      }
    </tr>
  )
}

export default TableRow