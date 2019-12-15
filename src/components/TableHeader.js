import React from 'react'

const TableHeader = (props) => {
  return (
    <tr>
      {
        props.columns.map((column) => {
          return <th key={ column.id }>
              { column.name }
          </th>
        })
      }
    </tr>
  )
}

export default TableHeader