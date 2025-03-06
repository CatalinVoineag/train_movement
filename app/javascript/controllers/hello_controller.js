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


    // map animation?
    var times = 100
    var markers = []
    var coordinates = [ [ -2.2844621, 53.4802635 ], [ -2.2949851, 53.4816129 ], [ -2.2961463, 53.4817676 ], [ -2.2986936, 53.4821069 ], [ -2.3015444, 53.4824732 ], [ -2.3032746, 53.4826923 ], [ -2.3046137, 53.4828642 ], [ -2.3059454, 53.4830218 ], [ -2.3086099, 53.4833331 ], [ -2.3097606, 53.4834633 ], [ -2.3106654, 53.4835656 ], [ -2.3128408, 53.483794 ], [ -2.31464, 53.4839814 ], [ -2.3164028, 53.4841509 ], [ -2.317015, 53.4842053 ], [ -2.3204599, 53.4845091 ], [ -2.3243788, 53.4848695 ], [ -2.3269614, 53.4850913 ], [ -2.3282498, 53.4851916 ], [ -2.330051, 53.4853013 ], [ -2.3311875, 53.4853653 ], [ -2.3327109, 53.4854451 ], [ -2.3339719, 53.4855068 ], [ -2.3341123, 53.485513 ] ]

    //const sleepNow = (delay) => new Promise((resolve) => setTimeout(resolve, delay))

    //async function repeatedGreetingsLoop() {
    //  for (let i = 0; i <= coordinates.length; i++) {
    //    await sleepNow(1000)
    //    setTimeout(() => {
    //      // Remove old marker
    //      if (markers.length > 0 && i < coordinates.length) {
    //        mapObject.removeLayer(markers[0])
    //        markers.shift()
    //      }

    //      console.log(coordinates[i])
    //      markers.push(L.marker(coordinates[i].reverse()).addTo(mapObject))
    //    }, 50)
    //  }
    //}

    //repeatedGreetingsLoop()
    //

    new L.TileLayer('http://{s}.tiles.openrailwaymap.org/standard/{z}/{x}/{y}.png',
      {
        attribution: '<a href="https://www.openstreetmap.org/copyright">© OpenStreetMap contributors</a>, Style: <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA 2.0</a> <a href="http://www.openrailwaymap.org/">OpenRailwayMap</a> and OpenStreetMap',
        minZoom: 2,
        maxZoom: 19,
        tileSize: 256
      }).addTo(mapObject);

    L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(mapObject);




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

        var marker = L.marker([parseFloat(data.lat), parseFloat(data.long)],{alt: data.train_id}).addTo(mapObject)

        marker.on('click', function() {
          L.popup()
            .setLatLng(this._latlng)
            .setContent(`Train ID ${data.train_id}`)
            .openOn(mapObject);
        });

        hash.set(data.train_id, marker)
      }
    });
  }
}
