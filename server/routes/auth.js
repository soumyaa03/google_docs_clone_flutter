const express = require("express");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const auth = require("../middleware/auth");
const authRouter = express.Router();

authRouter.post("/api/signup", async (req,res) => {
    try {
        const {name , email , profilePic} = req.body;

        //email already exists ? 
        let user = await User.findOne({email : email});

        if(!user) {

            user = new User({
                email : email,
                profilePic : profilePic,
                name : name,
            });
            user = await user.save();
        }
         const token = jwt.sign({ id : user._id } , "passwordKey");
        // when key and value are same name , then instead of user:user we can use only user or instead of email:email =. we can use just mail
        //res.json({user:user});
        res.json({user,token});
    } catch (e) {

        res.status(500).json({error : e.message});
        
    }
});

authRouter.get("/", auth, async(req,res) => {
    try {
        const user = await User.findById(req.user);
    // const token = user.token;
    // res.json({user,token});
    res.json({user,token : user.token});
    } catch (e) {
        res.status(500).json({error : e.message});
    }
});


module.exports = authRouter;



