 const functi = required('firebase-functions');   

exports.func = functions.https.orRequest((req, res) => {
    var admin = require("firebase-admin");
    var serviceAccount = require("./test-4bd9d-firebase-adminsdk-x1dmh-24868267c0.json");
    const fetch = require("node-fetch");
    var lat1 = req.lat;
    var lon1 = req.lon;
    var lat = 0;
    var lon = 0;
    var due = 0;

    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://test-4bd9d.firebaseio.com" 
    });

    const db = admin.firestore();

    db.collection('agents').get().then((snapshot)=> {
        snapshot.docs.forEach(doc=> {
            var lat2 = doc.get().lat;
            var lon2 = doc.get().long;
            fetch("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${lat1}|${lon1}&destinations=${lat2}|${lon2}&key=AIzaSyCYFHrrVM-Pi6JwPp1xtnol3cV7FuRLTzo").then((response) => {
                if(response.duration > due){
                    due = response.duration;
                    lat = lat2;
                    lon = lon2;
                }
            })
        })
    })
    return [res.lat, res.lon];
})   
    

