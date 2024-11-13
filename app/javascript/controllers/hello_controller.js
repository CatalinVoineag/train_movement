import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"
import "leaflet"
import "leaflet-css"

L.Icon.Default.imagePath = 'images';

var mapObject = ""
var hash = ""

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.setupMap()
    this.createSocket()

  }

  setupMap() {
    mapObject = L.map(this.containerTarget).setView([52.505, -0.50], 7);
    hash = new Map();


    //L.tileLayer('https://maptiles.p.rapidapi.com/es/map/v1/{z}/{x}/{y}.png', {
    //    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    //}).addTo(mapObject);

    // map animation?
    //var times = 100
    //var markers = []

    //const sleepNow = (delay) => new Promise((resolve) => setTimeout(resolve, delay))

    //async function repeatedGreetingsLoop() {
    //  for (let i = 1; i <= times; i++) {
    //    await sleepNow(1000)
    //    setTimeout(() => {
    //      // Remove old marker
    //      if (markers.length > 0) {
    //        mapObject.removeLayer(markers[0])
    //        markers.shift()
    //      }

    //      markers.push(L.marker([(52.0 + (i * 0.001)), -0.50]).addTo(mapObject))
    //    }, 50)
    //  }
    //}

    //repeatedGreetingsLoop()


    var openrailwaymap = new L.TileLayer('http://{s}.tiles.openrailwaymap.org/standard/{z}/{x}/{y}.png',
      {
        attribution: '<a href="https://www.openstreetmap.org/copyright">© OpenStreetMap contributors</a>, Style: <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA 2.0</a> <a href="http://www.openrailwaymap.org/">OpenRailwayMap</a> and OpenStreetMap',
        minZoom: 2,
        maxZoom: 19,
        tileSize: 256
      }).addTo(mapObject);



    L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(mapObject);

    //L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    //    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    //}).addTo(mapObject);
}

  createSocket() {
    createConsumer().subscriptions.create("TrainMovementChannel", {
      connected() {
        console.log("Client Connected")
      },

      disconnected() {
        console.log("Client Disconnected")
      },

      received(data) {
        var oldMarker = hash.get(data.train_id)

        if (oldMarker) {
          mapObject.removeLayer(oldMarker)
        }

        var marker = L.marker([parseFloat(data.lat), parseFloat(data.long)]).addTo(mapObject)
        marker.bindPopup(data.train_id)
        hash.set(data.train_id, marker)

        console.log(hash)
      }
    });
  }
}
