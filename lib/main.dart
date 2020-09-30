import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(NewsApp());

class NewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "News App",
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Category>> getCategoris() async {
    var url = "https://strapi-mongodb-cloudinary.herokuapp.com/categories";
    var response = await http.get(url);
    var jsonString = response.body;
    List<Category> categories = categoryFromJson(jsonString);
    //print(jsonString);

    return categories;
  }

  @override
  void initState() {
    super.initState();
    //getCategoris().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("موجز الأخبار"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FutureBuilder<List<Category>>(
            future: getCategoris(),
            builder: (context, snapshot) {
              return snapshot.data == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemCount:
                            snapshot.data == null ? 0 : snapshot.data.length,
                        itemBuilder: (context, index) {
                          Category item = snapshot.data[index];
                          return InkWell(
                            child: GridTile(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  item.name,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: NetworkImage(item.image.url),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ArticlesScreen(
                                        articlesList: item.articles,
                                        catName: item.name))),
                          );
                        },
                      ),
                    );
            },
          )
        ],
      ),
    );
  }
}

// Articles List Screen
class ArticlesScreen extends StatelessWidget {
  final List<Article> articlesList;
  final String catName;

  const ArticlesScreen({Key key, this.articlesList, this.catName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(catName),
      ),
      body: ListView.builder(
        itemCount: articlesList.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  articlesList[index].title,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(articlesList[index].image.url),
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailsScreen(
                            articleDetails: articlesList[index]))),
              ),
            ),
          );
        },
      ),
    );
  }
}

//Details Screen

class DetailsScreen extends StatelessWidget {
  final Article articleDetails;

  const DetailsScreen({Key key, this.articleDetails}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(articleDetails.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Text(
            articleDetails.title,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(articleDetails.image.url),
                      fit: BoxFit.cover),
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)],
                  border: Border.all(color: Colors.black, width: 1)),
            ),
          ),
          Text(
            articleDetails.content,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          RaisedButton(
              padding: EdgeInsets.all(5),
              child: Text("رابط الخبر"),
              color: Colors.deepPurple,
              textColor: Colors.white,
              onPressed: () {
                launch(articleDetails.source);
              })
        ],
      ),
    );
  }
}
// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

List<Category> categoryFromJson(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
  Category({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.image,
    this.articles,
    this.categoryId,
  });

  String id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  Image image;
  List<Article> articles;
  String categoryId;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["_id"],
        name: json["name"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        image: Image.fromJson(json["image"]),
        articles: List<Article>.from(
            json["articles"].map((x) => Article.fromJson(x))),
        categoryId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "image": image.toJson(),
        "articles": List<dynamic>.from(articles.map((x) => x.toJson())),
        "id": categoryId,
      };
}

class Article {
  Article({
    this.id,
    this.source,
    this.title,
    this.description,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.category,
    this.image,
    this.articleId,
  });

  String id;
  String source;
  String title;
  String description;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String category;
  Image image;
  String articleId;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json["_id"],
        source: json["source"],
        title: json["title"],
        description: json["description"],
        content: json["content"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        category: json["category"],
        image: Image.fromJson(json["image"]),
        articleId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "source": source,
        "title": title,
        "description": description,
        "content": content,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "category": category,
        "image": image.toJson(),
        "id": articleId,
      };
}

class Image {
  Image({
    this.id,
    this.name,
    this.alternativeText,
    this.caption,
    this.hash,
    this.ext,
    this.mime,
    this.size,
    this.url,
    this.providerMetadata,
    this.formats,
    this.provider,
    this.width,
    this.height,
    this.related,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.imageId,
  });

  String id;
  String name;
  String alternativeText;
  String caption;
  String hash;
  String ext;
  String mime;
  double size;
  String url;
  ProviderMetadata providerMetadata;
  Formats formats;
  String provider;
  int width;
  int height;
  List<String> related;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String imageId;

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["_id"],
        name: json["name"],
        alternativeText: json["alternativeText"],
        caption: json["caption"],
        hash: json["hash"],
        ext: json["ext"],
        mime: json["mime"],
        size: json["size"].toDouble(),
        url: json["url"],
        providerMetadata: ProviderMetadata.fromJson(json["provider_metadata"]),
        formats: Formats.fromJson(json["formats"]),
        provider: json["provider"],
        width: json["width"],
        height: json["height"],
        related: List<String>.from(json["related"].map((x) => x)),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        imageId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "alternativeText": alternativeText,
        "caption": caption,
        "hash": hash,
        "ext": ext,
        "mime": mime,
        "size": size,
        "url": url,
        "provider_metadata": providerMetadata.toJson(),
        "formats": formats.toJson(),
        "provider": provider,
        "width": width,
        "height": height,
        "related": List<dynamic>.from(related.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "id": imageId,
      };
}

class Formats {
  Formats({
    this.thumbnail,
  });

  Thumbnail thumbnail;

  factory Formats.fromJson(Map<String, dynamic> json) => Formats(
        thumbnail: Thumbnail.fromJson(json["thumbnail"]),
      );

  Map<String, dynamic> toJson() => {
        "thumbnail": thumbnail.toJson(),
      };
}

class Thumbnail {
  Thumbnail({
    this.hash,
    this.ext,
    this.mime,
    this.width,
    this.height,
    this.size,
    this.path,
    this.url,
    this.providerMetadata,
  });

  String hash;
  String ext;
  String mime;
  int width;
  int height;
  double size;
  dynamic path;
  String url;
  ProviderMetadata providerMetadata;

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
        hash: json["hash"],
        ext: json["ext"],
        mime: json["mime"],
        width: json["width"],
        height: json["height"],
        size: json["size"].toDouble(),
        path: json["path"],
        url: json["url"],
        providerMetadata: ProviderMetadata.fromJson(json["provider_metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "hash": hash,
        "ext": ext,
        "mime": mime,
        "width": width,
        "height": height,
        "size": size,
        "path": path,
        "url": url,
        "provider_metadata": providerMetadata.toJson(),
      };
}

class ProviderMetadata {
  ProviderMetadata({
    this.publicId,
    this.resourceType,
  });

  String publicId;
  String resourceType;

  factory ProviderMetadata.fromJson(Map<String, dynamic> json) =>
      ProviderMetadata(
        publicId: json["public_id"],
        resourceType: json["resource_type"],
      );

  Map<String, dynamic> toJson() => {
        "public_id": publicId,
        "resource_type": resourceType,
      };
}
