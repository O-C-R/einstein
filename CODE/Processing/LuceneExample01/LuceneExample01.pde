// http://stackoverflow.com/questions/1844194/get-cosine-similarity-between-two-documents-in-lucene

// http://filotechnologia.blogspot.com/2014/01/a-simple-java-class-for-tfidf-scoring.html

// https://gist.github.com/butlermh/4672977


// this is a simple lucene example to search the docs
// http://www.lucenetutorial.com/code/HelloLucene.java
// http://www.lucenetutorial.com/lucene-in-5-minutes.html

import java.io.IOException;
import java.util.*;
import java.util.Map;
import java.util.Set;


//
void setup() {

  // 1: make index
  StandardAnalyzer analyzer = new StandardAnalyzer(Version.LUCENE_40);
  Directory index = new RAMDirectory();
  IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_40, analyzer);
  try {
    IndexWriter w = new IndexWriter(index, config);

    addDoc(w, "Lucene in Action", "193398817");
    addDoc(w, "Lucene for Dummies", "55320055Z");
    addDoc(w, "Managing Gigabytes", "55063554A");
    addDoc(w, "The Art of Computer Science", "9900333X");
    w.close();
  }
  catch (Exception e) {
    println("problem with addDoc");
  }

  // 2: query
  //String querystr = args.length > 0 ? args[0] : "lucene";
  String querystr = "lucene";
  Query query = null;
  try {
    org.apache.lucene.queryparser.classic.QueryParser qp = new org.apache.lucene.queryparser.classic.QueryParser(Version.LUCENE_40, "title", analyzer); // .parse(querystr);
    query = qp.parse(querystr);
  }
  catch (Exception e) {
    println("problem with query");
  }

  // 3: search
  if (query != null) {
    try {
      int hitsPerPage = 10;
      IndexReader reader = DirectoryReader.open(index);
      IndexSearcher searcher = new IndexSearcher(reader);
      TopScoreDocCollector collector = TopScoreDocCollector.create(hitsPerPage, true);
      searcher.search(query, collector);
      ScoreDoc[] hits = collector.topDocs().scoreDocs;

      // 4: display results
      System.out.println("Found " + hits.length + " hits.");
      for (int i=0; i<hits.length; ++i) {
        int docId = hits[i].doc;
        Document d = searcher.doc(docId);
        System.out.println((i + 1) + ". " + d.get("isbn") + "\t" + d.get("title"));
      }

      // reader can only be closed when there
      // is no need to access the documents any more.
      reader.close();
    } 
    catch (Exception e) {
      println("problem with search");
    }
  } else {
    println("query is null.  no search");
  }
} // end setup

private static void addDoc(IndexWriter w, String title, String isbn) throws IOException {
  Document doc = new Document();
  doc.add(new TextField("title", title, org.apache.lucene.document.Field.Store.YES));
  doc.add(new StringField("isbn", isbn, org.apache.lucene.document.Field.Store.YES));
  w.addDocument(doc);
} // end addDoc
//
//
//
//
//
//

