
class DataLoader {
  constructor (data) {
    this.data = data
    this.teams = {}
  }

  import = () => {
    console.log('importing', this.data)
    return Object.values(this.teams)
  }
}

export const dataFromFilename = (filename) => {
  return fetch(filename).then(response => {
    return response.json()
  })
}

export default DataLoader