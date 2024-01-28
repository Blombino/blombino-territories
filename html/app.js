function main(){
    return {
        show: false,
        percent: 100,
        label: 'NULL',
        owner: 'Blombino community the best in the world',
        listen(){
            window.addEventListener('message', (event) => {
                let data = event.data
                switch(data.type){
                    case 'ui':
                        this.show = data.show
                        break;
                    case 'update':
                        this.percent = Math.floor(getPercent(data.max, data.curr) * 10) / 10
                        this.label = data.name
                        this.owner = data.owner
                        break;
                }             
            })
        }
    }
}

function getPercent(max, curr){
    return (curr * 100) / max
}
