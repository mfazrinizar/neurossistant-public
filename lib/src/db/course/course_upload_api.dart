import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CourseUploadApi {
  static void uploadCourseData() async {
    // Reference to the Firestore collection
    CollectionReference courses =
        FirebaseFirestore.instance.collection('courses');

    // Course data template without courseId
    Map<String, dynamic> courseData = {
      "title": {
        "en": "Parenting for Autistic Children",
        "id": "Parenting untuk Anak-anak Autistik"
      },
      "description": {
        "en":
            "This course is designed to help parents understand and support their autistic children.",
        "id":
            "Kursus ini dirancang untuk membantu orang tua memahami dan mendukung anak-anak autistik mereka."
      },
      "dateTime": DateTime.now(),
      "popularity": 0,
      "psychologist": "Dr. Raihan, M.Psi.",
      "psychologistId": "ikifjenf",
      "durations": 16,
      "sessions": 8,
      "tag": "ASD",
      "imageUrl": "assets/images/asdTagOrange.svg",
    };

    Map<String, dynamic> preTestData = {
      "preTest": {
        "questions": [
          {
            "question": {"en": "What is autism?", "id": "Apa itu autisme?"},
            "options": {
              "A": {
                "en":
                    "Autism is a developmental disorder characterized by difficulties with social interaction and communication, and by restricted and repetitive behavior.",
                "id":
                    "Autisme adalah gangguan perkembangan yang ditandai dengan kesulitan dalam interaksi sosial dan komunikasi, serta perilaku terbatas dan berulang."
              },
              "B": {
                "en":
                    "Autism is a psychological condition that affects emotional regulation.",
                "id":
                    "Autisme adalah kondisi psikologis yang memengaruhi regulasi emosional."
              },
              "C": {
                "en":
                    "Autism is a type of physical disability that impacts motor skills.",
                "id":
                    "Autisme adalah jenis disabilitas fisik yang mempengaruhi keterampilan motorik."
              },
              "D": {
                "en":
                    "Autism is a genetic disorder that primarily affects cognitive development.",
                "id":
                    "Autisme adalah gangguan genetik yang terutama mempengaruhi perkembangan kognitif."
              },
              "E": {
                "en":
                    "Autism is a contagious disease that can be spread through physical contact.",
                "id":
                    "Autisme adalah penyakit menular yang dapat menyebar melalui kontak fisik."
              }
            },
            "correctAnswer": "A"
          },
          {
            "question": {
              "en": "What are common signs of autism in children?",
              "id": "Apa saja tanda-tanda umum autisme pada anak-anak?"
            },
            "options": {
              "A": {
                "en":
                    "Children with autism typically have exceptional motor skills and easily make friends.",
                "id":
                    "Anak-anak dengan autisme biasanya memiliki keterampilan motorik yang luar biasa dan mudah berteman."
              },
              "B": {
                "en":
                    "Children with autism often display repetitive behaviors and have difficulties with social interactions and communication.",
                "id":
                    "Anak-anak dengan autisme sering menunjukkan perilaku berulang dan mengalami kesulitan dalam interaksi sosial dan komunikasi."
              },
              "C": {
                "en":
                    "Children with autism usually excel in emotional regulation and have no speech delays.",
                "id":
                    "Anak-anak dengan autisme biasanya unggul dalam regulasi emosional dan tidak mengalami keterlambatan bicara."
              },
              "D": {
                "en":
                    "Children with autism rarely have any sensory sensitivities.",
                "id":
                    "Anak-anak dengan autisme jarang memiliki sensitivitas sensorik."
              },
              "E": {
                "en":
                    "Children with autism are very social and enjoy being the center of attention.",
                "id":
                    "Anak-anak dengan autisme sangat sosial dan senang menjadi pusat perhatian."
              }
            },
            "correctAnswer": "B"
          },
          {
            "question": {
              "en":
                  "Which of the following therapies is commonly used to support children with autism?",
              "id":
                  "Manakah dari terapi berikut yang umumnya digunakan untuk mendukung anak-anak dengan autisme?"
            },
            "options": {
              "A": {
                "en": "Speech therapy is rarely used for children with autism.",
                "id":
                    "Terapi bicara jarang digunakan untuk anak-anak dengan autisme."
              },
              "B": {
                "en":
                    "Physical therapy is the only therapy used for children with autism.",
                "id":
                    "Terapi fisik adalah satu-satunya terapi yang digunakan untuk anak-anak dengan autisme."
              },
              "C": {
                "en":
                    "Applied Behavior Analysis (ABA) therapy is commonly used to support children with autism.",
                "id":
                    "Terapi Analisis Perilaku Terapan (ABA) sering digunakan untuk mendukung anak-anak dengan autisme."
              },
              "D": {
                "en": "Therapies are not necessary for children with autism.",
                "id": "Terapi tidak diperlukan untuk anak-anak dengan autisme."
              },
              "E": {
                "en":
                    "None of the above therapies are used for children with autism.",
                "id":
                    "Tidak ada dari terapi di atas yang digunakan untuk anak-anak dengan autisme."
              }
            },
            "correctAnswer": "C"
          },
        ]
      },
    };

    Map<String, dynamic> postTestData = {
      "postTest": {
        "questions": [
          {
            "question": {"en": "What is autism?", "id": "Apa itu autisme?"},
            "options": {
              "A": {
                "en":
                    "Autism is a developmental disorder characterized by difficulties with social interaction and communication, and by restricted and repetitive behavior.",
                "id":
                    "Autisme adalah gangguan perkembangan yang ditandai dengan kesulitan dalam interaksi sosial dan komunikasi, serta perilaku terbatas dan berulang."
              },
              "B": {
                "en":
                    "Autism is a psychological condition that affects emotional regulation.",
                "id":
                    "Autisme adalah kondisi psikologis yang memengaruhi regulasi emosional."
              },
              "C": {
                "en":
                    "Autism is a type of physical disability that impacts motor skills.",
                "id":
                    "Autisme adalah jenis disabilitas fisik yang mempengaruhi keterampilan motorik."
              },
              "D": {
                "en":
                    "Autism is a genetic disorder that primarily affects cognitive development.",
                "id":
                    "Autisme adalah gangguan genetik yang terutama mempengaruhi perkembangan kognitif."
              },
              "E": {
                "en":
                    "Autism is a contagious disease that can be spread through physical contact.",
                "id":
                    "Autisme adalah penyakit menular yang dapat menyebar melalui kontak fisik."
              }
            },
            "correctAnswer": "A"
          },
          {
            "question": {
              "en": "What are common signs of autism in children?",
              "id": "Apa saja tanda-tanda umum autisme pada anak-anak?"
            },
            "options": {
              "A": {
                "en":
                    "Children with autism typically have exceptional motor skills and easily make friends.",
                "id":
                    "Anak-anak dengan autisme biasanya memiliki keterampilan motorik yang luar biasa dan mudah berteman."
              },
              "B": {
                "en":
                    "Children with autism often display repetitive behaviors and have difficulties with social interactions and communication.",
                "id":
                    "Anak-anak dengan autisme sering menunjukkan perilaku berulang dan mengalami kesulitan dalam interaksi sosial dan komunikasi."
              },
              "C": {
                "en":
                    "Children with autism usually excel in emotional regulation and have no speech delays.",
                "id":
                    "Anak-anak dengan autisme biasanya unggul dalam regulasi emosional dan tidak mengalami keterlambatan bicara."
              },
              "D": {
                "en":
                    "Children with autism rarely have any sensory sensitivities.",
                "id":
                    "Anak-anak dengan autisme jarang memiliki sensitivitas sensorik."
              },
              "E": {
                "en":
                    "Children with autism are very social and enjoy being the center of attention.",
                "id":
                    "Anak-anak dengan autisme sangat sosial dan senang menjadi pusat perhatian."
              }
            },
            "correctAnswer": "B"
          },
          {
            "question": {
              "en":
                  "Which of the following therapies is commonly used to support children with autism?",
              "id":
                  "Manakah dari terapi berikut yang umumnya digunakan untuk mendukung anak-anak dengan autisme?"
            },
            "options": {
              "A": {
                "en": "Speech therapy is rarely used for children with autism.",
                "id":
                    "Terapi bicara jarang digunakan untuk anak-anak dengan autisme."
              },
              "B": {
                "en":
                    "Physical therapy is the only therapy used for children with autism.",
                "id":
                    "Terapi fisik adalah satu-satunya terapi yang digunakan untuk anak-anak dengan autisme."
              },
              "C": {
                "en":
                    "Applied Behavior Analysis (ABA) therapy is commonly used to support children with autism.",
                "id":
                    "Terapi Analisis Perilaku Terapan (ABA) sering digunakan untuk mendukung anak-anak dengan autisme."
              },
              "D": {
                "en": "Therapies are not necessary for children with autism.",
                "id": "Terapi tidak diperlukan untuk anak-anak dengan autisme."
              },
              "E": {
                "en":
                    "None of the above therapies are used for children with autism.",
                "id":
                    "Tidak ada dari terapi di atas yang digunakan untuk anak-anak dengan autisme."
              }
            },
            "correctAnswer": "C"
          },
        ]
      },
    };

    Map<String, dynamic> sessions = {
      "sessions": [
        {
          "sessionNumber": 1,
          "sessionTitle": {
            "id": "Memahami Gangguan Spektrum Autisme (ASD)",
            "en": "Understanding Autism Spectrum Disorder (ASD)"
          },
          "duration": 2,
          "materials": [
            {
              "type": "video",
              "content": {
                "en": "https://www.youtube.com/watch?v=tEBsTX2OVgI",
                "id": "https://www.youtube.com/watch?v=DwXRIu0esT0"
              }
            },
            {
              "type": "article",
              "content": {
                "en":
                    "This%20is%20an%20article%20text.%20%0A%0AThis%20is%20a%20new%20paragraph.%0A%0AThis%20is%20another%20paragraph.",
                "id":
                    "Ini%20adalah%20teks%20artikel.%20%0A%0AIni%20adalah%20sebuah%20paragraf%20baru.%0A%0AIni%20adalah%20paragraf%20baru%20lainnya."
              }
            },
            {
              "type": "pdf",
              "content": {
                "en":
                    "https://mfazrinizar.github.io/assets/(Neurodivergent%20Population%20Percentage)%20Neurodiversity%20at%20work%20a%20biopsychosocial%20model.pdf",
                "id":
                    "https://mfazrinizar.github.io/assets/(Neurodivergent%20Population%20Percentage)%20Neurodiversity%20at%20work%20a%20biopsychosocial%20model.pdf"
              }
            }
          ],
          "task": {
            "description": {
              "en": "Submit a summary of the session.",
              "id": "Kirim ringkasan sesi."
            },
            "acceptedFileTypes": ["docx", "pdf", "txt"]
          },
          "commentsList": [
            {
              "avatarUrl":
                  "https://firebasestorage.googleapis.com/v0/b/neurossistant.appspot.com/o/profile_pictures%2FbvuSjWQaRbOERzGl2kdrfpw0Kyv1.jpg?alt=media&token=aaca9c43-a5b4-40f3-a422-d5342fbe1a36",
              "commentDate": DateTime.now(),
              "commentId": "uniqueId-00",
              "commenterId": "BtQDQqqimzdwyAaVMCzujSIxGlo1",
              "commenterName": "Raihan",
              "text": "This session was very informative."
            },
            {
              "avatarUrl":
                  "https://firebasestorage.googleapis.com/v0/b/neurossistant.appspot.com/o/profile_pictures%2FbvuSjWQaRbOERzGl2kdrfpw0Kyv1.jpg?alt=media&token=aaca9c43-a5b4-40f3-a422-d5342fbe1a36",
              "commentDate": DateTime.now(),
              "commentId": "uniqueId-01",
              "commenterId": "BtQDQqqimzdwyAaVMCzujSIxGlo1",
              "commenterName": "Raihan",
              "text": "I found the video particularly helpful."
            }
          ]
        },
        {
          "sessionNumber": 2,
          "sessionTitle": {
            "id": "Judul Sesi yang Lain",
            "en": "Another Session Title"
          },
          "duration": 2,
          "materials": [
            {
              "type": "video",
              "content": {
                "en": "https://youtube.com/example2",
                "id": "https://youtube.com/example2"
              }
            },
            {
              "type": "article",
              "content": {
                "en": "This is another article text.",
                "id": "Ini adalah teks artikel lain."
              }
            }
          ],
          "task": {
            "description": {
              "en": "Submit your thoughts on the session.",
              "id": "Kirimkan pendapat Anda tentang sesi tersebut."
            },
            "acceptedFileTypes": ["docx", "pdf", "txt", "direct"]
          }
        }
      ],
    };

    try {
      DocumentReference docRef = await courses.add(courseData);
      String courseId = docRef.id;

      await docRef.update({"courseId": courseId});

      CollectionReference contentsCollection = docRef.collection('contents');

      await contentsCollection.doc('preTest').set(preTestData);

      await contentsCollection.doc('postTest').set(postTestData);

      await contentsCollection.doc('sessions').set(sessions);

      if (kDebugMode) {
        debugPrint(
            "Course data uploaded successfully with courseId: $courseId");
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Failed to upload course data: $e");
    }
  }
}
