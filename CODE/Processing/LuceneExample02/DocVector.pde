public class DocVector {

  public Map terms;
  public OpenMapRealVector vector;

  public DocVector(Map terms) {
    this.terms = terms;
    this.vector = new OpenMapRealVector(terms.size());
  }

  public void setEntry(String term, int freq) {
    if (terms.containsKey(term)) {
      int pos = (Integer)terms.get(term);
      vector.setEntry(pos, (double) freq);
    }
  }

  public void normalize() {
    double sum = vector.getL1Norm();
    vector = (OpenMapRealVector) vector.mapDivide(sum);
  }

  @Override
    public String toString() {
    RealVectorFormat formatter = new RealVectorFormat();
    return formatter.format(vector);
  }
} // end class DocVector

//
//
//
//
//
//



/**
 * Class to calculate cosine similarity
 * @author Mubin Shrestha
 */
public class CosineSimilarity {    
  public double CosineSimilarity(DocVector d1, DocVector d2) {
    double cosinesimilarity;
    try {
      cosinesimilarity = (d1.vector.dotProduct(d2.vector))
        / (d1.vector.getNorm() * d2.vector.getNorm());
    } 
    catch (Exception e) {
      return 0.0;
    }
    return cosinesimilarity;
  }
} // end class CosineSimilarity

//
//
//
//
//
//



/**
 * Class to generate Document Vectors from Lucene Index
 * @author Mubin Shrestha
 */
public class VectorGenerator {
  DocVector[] docVector;
  private Map allterms;
  Integer totalNoOfDocumentInIndex;
  IndexReader indexReader;

  public VectorGenerator() throws IOException
  {
    allterms = new HashMap();
    indexReader = IndexOpener.GetIndexReader();
    totalNoOfDocumentInIndex = IndexOpener.TotalDocumentInIndex();
    docVector = new DocVector[totalNoOfDocumentInIndex];
  }

  public void GetAllTerms() throws IOException
  {
    AllTerms allTerms = new AllTerms();
    allTerms.initAllTerms();
    allterms = allTerms.getAllTerms();
  }

  public DocVector[] GetDocumentVectors() throws IOException {
    for (int docId = 0; docId < totalNoOfDocumentInIndex; docId++) {
      Terms vector = indexReader.getTermVector(docId, Configuration.FIELD_CONTENT);
      TermsEnum termsEnum = null;
      termsEnum = vector.iterator(termsEnum);
      BytesRef text = null;            
      docVector[docId] = new DocVector(allterms);            
      while ( (text = termsEnum.next ()) != null) {
        String term = text.utf8ToString();
        int freq = (int) termsEnum.totalTermFreq();
        docVector[docId].setEntry(term, freq);
      }
      docVector[docId].normalize();
    }        
    indexReader.close();
    return docVector;
  }
} // end class VectorGenerator

//
//
//
//
//
//

