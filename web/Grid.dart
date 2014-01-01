library grid;

import 'dart:math';


class Grid {
  int w, h;
  List data;
  List cols;
  Grid(this.w, this.h) {
    data = new List(w * h);
    cols = new List(w);
    for (int x = 0; x < w; x++) {
      cols[x] = new GridCol(data, x, w);
    }
  }
  GridCol operator [](int x) {
    return cols[x];
  }
  
  Point<int> find(var object){
    var index = data.indexOf(object);
    if (index == -1){
      return null;
    }else{
      return new Point((index % w).toInt(), index ~/ w);
    }
  }
}

class GridCol {
  int x, w;
  List data;
  GridCol(this.data, this.x, this.w);
  Object operator [](int y) {
    return data[x + y * w];
  }
  void operator []= (int y, var value) {
    data[x + y * w] = value;
  }
}

