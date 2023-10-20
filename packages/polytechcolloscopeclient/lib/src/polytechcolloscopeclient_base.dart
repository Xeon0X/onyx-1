import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:requests_plus/requests_plus.dart';

import 'colloscope_datastructs.dart';
import 'consts.dart';

class PolytechColloscopeClient {
  final String _username, _password;

  PolytechColloscopeClient(this._username, this._password) {
    assert(_username.isNotEmpty);
    assert(_password.isNotEmpty);
  }

  Future<List<Student>> fetchStudents(Year year) async {
    var page = await RequestsPlus.get(Consts.kholleURL[year]!,
        userName: _username, password: _password);

    BeautifulSoup bs = BeautifulSoup(page.body);

    //This isolates the student list part of the page, it consists in a list of <li> elements like
    // <li><a href="?page=colles_2A&amp;id_etudiant=STUDENT_ID">INITAL. SUNRNAME</a> (groupe GROUPNUMBER)</li>
    var studentsList = bs.find("table.colles")?.find("td > ul");

    List<Student> students = [];

    studentsList?.findAll("li > a").forEach((e) {
      var name = e.innerHtml;
      var link = e.getAttrValue("href");
      var id = RegExp(r"id_etudiant=(\d+)").firstMatch(link!)?.group(1);

      students.add(Student(name, int.parse(id!)));
    });

    return students;
  }

  Future<Student?> fetchStudent(Year year, String name, String surname) async {
    if (name.isEmpty || surname.isEmpty) {
      return null;
    }

    String match =
        "${name.substring(0, 1).toUpperCase()}. ${surname.toUpperCase()}";

    var students = await fetchStudents(year);
    return students.firstWhereOrNull((s) => s.name == match);
  }

  Future<StudentColloscope> getColloscope(Year year, Student student) async {
    // TODO : Add a check to verify the studentid (look 5 lines below)

    var page = await RequestsPlus.get(
        Consts.khollesStudentURL[year]!
            .replaceFirst(":id", student.id.toString()),
        userName: _username,
        password: _password);

    BeautifulSoup bs = BeautifulSoup(page.body);

    // We can use this to check if the studentid is valid
    var header = bs.find("h3.colles");
    if (header == null) {
      throw StateError("Invalid student id");
    }

    var trinomeStr = RegExp(r"trinôme (\d+)").firstMatch(header.innerHtml)?.group(1);

    var trinome = int.parse(trinomeStr!);

    var tableHtml = bs.find("table.colles");

    List kholles = [];

    tableHtml?.findAll("tr").forEach((e) {
      kholles.add(parseKholle(e));
    });

    return StudentColloscope(student, trinome, kholles);
  }

  static Kholle parseKholle(Bs4Element e) {
    // Gathering data from html (this parsing is awful but can't really do better)

    var date = e.children.first.innerHtml.trim();
    var secondTd = e.children.elementAtOrNull(1);

    var hourAndMinute =
        secondTd?.children.first.innerHtml.replaceFirst("&nbsp;", "").trim();

    var secondDiv = secondTd?.children.elementAtOrNull(1);
    var kholleur = secondDiv?.find("a")?.text.trim();

    // This holds the subject of the kholle (and maybe the room because this website html is probably the worst I've ever seen)
    var text = "";

    var divText =
        secondDiv?.nodes.where((element) => element.runtimeType == Text);

    var subject = divText?.first.text?.replaceAll(RegExp(r'[()]'), "").trim();

    String message;
    if (divText?.length == 2) {
      message =
          divText?.last.text?.replaceAll(RegExp(r'[()]'), "").trim() ?? "";
    } else {
      message = "";
    }

    var dateParsed = RegExp(r"(\d{1,2}) (.{3,9})").firstMatch(date);
    var day = dateParsed?.group(1);
    var month = Consts.monthsTranslation[dateParsed?.group(2)];

    var hourAndMinutesParsed =
        RegExp(r"(\d{1,2}) h (\d{2})").firstMatch(hourAndMinute!);
    var hour = hourAndMinutesParsed?.group(1);
    var minutes = hourAndMinutesParsed?.group(2);

    var dateTime = DateTime(DateTime.now().year, month, int.parse(day!),
        int.parse(hour!), int.parse(minutes!));

    return Kholle(dateTime, subject!, message, kholleur);
  }
}
