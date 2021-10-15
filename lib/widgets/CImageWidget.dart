import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

cachedNetworkImage(mediaUrl) {
  return CircleAvatar(backgroundImage: CachedNetworkImageProvider(mediaUrl), backgroundColor: Colors.grey,);
}