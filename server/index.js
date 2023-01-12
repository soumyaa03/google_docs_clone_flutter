const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");


const PORT = process.env.PORT | 3001;

const app = express();

app.use(cors());

app.use(express.json());
//middle ware
app.use(authRouter);
// hex code for @ :- %40
// hex code for ' :- %27
// hex code for ' :- %21
app.use(documentRouter);

const DB = "mongodb+srv://Soumyaa03:Soumya%40123@cluster0.8jslvit.mongodb.net/?retryWrites=true&w=majority";
// encode special characters in password 

mongoose.connect(DB).then(() =>  {
    console.log("Connection Successful!");
})
.catch((err) => {
    console.log(err);
});
// 0.0.0.0 means IP address can be accessed from anywhere :// research more about it later 
app.listen(PORT, "0.0.0.0" , function ()  {
    //put back ticks for string interpolation
    console.log(`connected at port ${PORT}`);
    
});