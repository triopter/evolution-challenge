// If time allowed, I would really want some tests for this
export const objectComparator = (objA, objB, keys, direction) => {
  for (let i = 0; i < keys.length; i++) {
    let key = keys[i]
    let valA = objA[key]
    let valB = objB[key]

    if (valA === valB) {
      if ((i + 1) < keys.length) {
        return objectComparator(objA, objB, keys.slice(1), direction)
      }
      else {
        return 0
      }
    }
    return direction * (valA > valB ? 1 : -1)
  }
}