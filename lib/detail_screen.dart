// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final String imagesource;
  const DetailScreen({ Key? key, required this.imagesource }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Hero(
          tag: "Demo Tag",
          child: Container(
            height: 350,
            width: 350,    
            child: Image.network(widget.imagesource,fit: BoxFit.fill),
          )
        )
      ),
    );
  }
}