import 'dart:html';
import 'package:html5_dnd/html5_dnd.dart';
import 'Grid.dart';
import 'dart:math';

DraggableGroup innerGroup;
Grid grid;
var WIDTH = 40;
var HEIGHT;
Map<Element, Rivet> rivets = new Map();

void main() {
  var colarContainer = querySelector('#colar');
  List<DivElement> rows = colarContainer.querySelectorAll('.row');
  HEIGHT = rows.length;
  var bin = document.querySelector('#bin');
  grid = new Grid(WIDTH, rows.length);
  
  var y = 0;
  for(var row in rows){
    for(var x=0;x<WIDTH; x++){
      var div = new DivElement();
      div.classes.addAll(["selector","notselectable",'dropable','free']);
      row.children.add(div);
      grid[x][y] = div;
    }
    y++;
  }
  
  innerGroup = new DraggableGroup();
  DropzoneGroup binDropGroup = new DropzoneGroup()
    ..install(bin)
    ..onDrop.listen(_dropToBin);
  
  binDropGroup.accept.add(innerGroup);
  
  
  var draggables = querySelectorAll(".draggable");
  
  for(ImageElement image in draggables){
    var size = 1;
    if (image.width > 40){
      size = 2;
    }
    rivets[image] = new Rivet(size);
  }
  
  DraggableGroup dragGroup = new DraggableGroup()
    ..installAll(draggables)  
    ..onDragStart.listen(addBorders)
    ..onDragEnd.listen(removeBorders);
    
     
  
  DropzoneGroup dropGroup = new DropzoneGroup()
    ..installAll(querySelectorAll(".dropable"))
    ..accept.add(dragGroup)
    ..onDrop.listen(_onDrop)
    ..onDragEnter.listen(_onDragEnter)
    ..onDragLeave.listen(_onDragLeave);
}

void _onDragEnter(DropzoneEvent event) {
  Element dropTarget = event.dropzone;
  dropTarget.classes.add('over');
}

void _onDragLeave(DropzoneEvent event) {
  Element dropTarget = event.dropzone;
  dropTarget.classes.remove('over');
}

void _onDrop(DropzoneEvent event){
  Element dropTarget = event.dropzone;
  dropTarget.children.clear();
  
  var element = event.draggable.clone(false);
  innerGroup.install(element);
  dropTarget.children.add(element);
  dropTarget.classes.removeAll(['over', 'free']);
  dropTarget.classes.add('occupied');
  element.classes.add("centered");
  
  Point<int> point = grid.find(dropTarget);
  var rivet = rivets[event.draggable];
  rivets[element] = rivet;
  
  processNeighbors(point.x, point.y, hide, rivet.size);
  show(dropTarget);
}

void _onDragOver(MouseEvent event) {
  event.preventDefault();
}

void _dropToBin(DropzoneEvent event) {
  Element parent = event.draggable.parent;
  parent.classes.remove('occupied');
  parent.classes.add('free');
  Point<int> point = grid.find(parent);
  var rivet = rivets.remove(event.draggable);
  
  processNeighbors(point.x, point.y, show, rivet.size);
  event.draggable.remove();
}

void addBorders(DraggableEvent event){
  var elements = querySelectorAll('.selector');
  elements.classes.remove('invisBorder');
  elements.classes.add('withBorder');
}

void removeBorders(DraggableEvent event){
  var elements = querySelectorAll('.selector');
  elements.classes.remove('withBorder');
  elements.classes.add('invisBorder');
}

void processNeighbors(int x, int y, void operation(Element), int size){
    if (size > 0){
      if (x > 0){
        Element div = (grid[x-1][y]);
        operation(div);
        processNeighbors(x-1, y, operation, size-1);
      }
      if (x <WIDTH-1){
        Element div = (grid[x+1][y]);
        operation(div);
        processNeighbors(x+1, y, operation, size-1);
      }
      if (y > 0){
        Element div = (grid[x][y-1]);
        operation(div);
        processNeighbors(x, y-1, operation, size-1);
      }
      if (y < HEIGHT-1){
        Element div = (grid[x][y+1]);
        operation(div);
        processNeighbors(x, y+1, operation, size-1);
      }
    }
}
 
void show(Element div){
  div.classes.remove('invisible');
}

void hide(Element div){
  div.classes.add('invisible');  
}


class Rivet{
  String imagePath;
  int size = 1;
  
  Rivet(this.size);
  
  Rivet clone(){
    return new Rivet(size);
  }
}
