import 'dart:ui';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swipedetector/swipedetector.dart';
void main()=>runApp(App());
const String title='Programming Quotes';
class App extends StatelessWidget{
  @override
  Widget build(BuildContext c){
    return MaterialApp(
        debugShowCheckedModeBanner:false,title:title,
        theme:ThemeData(textTheme:Theme.of(c).textTheme.apply(bodyColor:Colors.white)),
        home:Scr());
  }
}
class QuoteCollection{
  int ps=0;
  final qts=new List<dynamic>();
  int l()=>qts.length;
  String toString()=>qts.map((e)=>{e['id'].toString()}).toList().join(',').replaceAll('{','').replaceAll("}",'');
  void shuffle(Random r){
    for(int i=0;i<l();++i){
      int p1=r.nextInt(l()),p2=r.nextInt(l());
      final x=qts[p2];qts[p2]=qts[p1];qts[p1]= x;}
  }
  void fwrd(){ps++;if(l()>0)ps%=l();}
  void back(){ps--;if(l()>0)ps=(ps+l())%l();}
}
class Scr extends StatefulWidget{
  @override
  ScrState createState()=>ScrState();
}
class ScrState extends State<Scr> {
  List<dynamic>_imagesList;
  QuoteCollection liked,notLiked,active,toAdd;
  Random r=new Random();
  String _author= "",_quote="",id,_img="assets/back.jpeg";
  bool likeBtn=false,likeMod=false;
  int times=0;
  double s=5,fs=30,fh=1.2;
  File f;
  @override
  void initState(){super.initState();init();}
  Future init()async{
    final quotesJson=await DefaultAssetBundle.of(context).loadString('assets/quotes.json');
    final imagesJson=await DefaultAssetBundle.of(context).loadString('assets/images.json');
    final tDir=await getApplicationDocumentsDirectory();
    final path=tDir.path+'/likes.txt';
    List<String>likes=[];
    f=new File(path);
    if(FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound){
    likes=f.readAsStringSync().split(',');}
    _imagesList=json.decode(imagesJson)['paths'];
    liked=QuoteCollection();notLiked=QuoteCollection();
    json.decode(quotesJson)['items'].forEach((e)=>{
    id=e['id'].toString(),
    toAdd=likes.contains(id)?liked:notLiked,
    toAdd.qts.add(e)});
    liked.shuffle(r);notLiked.shuffle(r);active=notLiked;
    show();
  }
  void fwd(){active.fwrd();show();}
  void back(){active.back();show();}
  void show(){setState((){
    likeBtn=likeMod;
    if(active.l()==0){_author="";_quote="No quotes yet!";likeBtn=false;}
    else{
      if (times==0){
        _img=_imagesList[r.nextInt(_imagesList.length)];
        s=r.nextDouble()*5+1;times=9;}
      times--;
      int ps=active.ps;_quote=active.qts[ps]['quote'];_author=active.qts[ps]['author'];
      final l=_quote.length;
      if(l<220){fs=30;fh=1.5;}else{fs=22;fh=1.3;}}
  });}
  void mode(){setState((){likeMod=!likeMod;active=likeMod?liked:notLiked;});show();}
  void like(){
    if (active.l()>0){setState((){
      likeBtn=!likeBtn;
      final from=likeMod?liked:notLiked;final to=likeMod?notLiked:liked;
      var t=from.qts[from.ps];from.qts.removeAt(from.ps);to.qts.add(t);
      active.fwrd();
    });
    f.writeAsStringSync(liked.toString());
    }
  }
  void share()=>Share.share("\""+_quote+"\" -"+_author+", shared from "+title);
  @override
  Widget build(BuildContext context) {
    final clr=Colors.black12;
    return Scaffold(body:
    SwipeDetector(
      child:Container(child:Container(decoration:BoxDecoration(
        gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.black,clr]),
        image:DecorationImage(image:Image.asset(_img).image,fit:BoxFit.cover)),
        child:BackdropFilter(filter:ImageFilter.blur(sigmaX:s,sigmaY:s),
            child:Container(decoration:BoxDecoration(color:Colors.transparent),
                child:Stack(children:<Widget>[Padding(padding:const EdgeInsets.all(24),
                 child: Center(child:Column(children:<Widget>[
                  Padding (padding:const EdgeInsets.only(top:32),child:Text(title,style:TextStyle(fontSize:20))),
                  Expanded(child:Align(alignment:Alignment.center,child:Text(_quote,style:TextStyle(fontSize:fs,height:fh)))),
                  Padding(padding:const EdgeInsets.only(bottom:32),child:Text(_author!=""?_author:"",style:TextStyle(fontSize:20))),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:<Widget>[
                   FloatingActionButton(child:Text('Liked'),onPressed:mode,backgroundColor:likeMod?Colors.black:clr,shape:likeMod?CircleBorder(side:BorderSide(color:Colors.white)):CircleBorder()),
                   FloatingActionButton(child:Icon(likeBtn?Icons.favorite:Icons.favorite_border),onPressed:like,backgroundColor:clr),
                   FloatingActionButton(onPressed:back,child:Icon(Icons.keyboard_arrow_left),backgroundColor:clr),
                   FloatingActionButton(onPressed:fwd,child:Icon(Icons.keyboard_arrow_right),backgroundColor:clr),
                   FloatingActionButton(onPressed:share,backgroundColor:clr,child:Icon(Icons.share))])],),),),],))))),
      onSwipeLeft:fwd,onSwipeRight:back));}}