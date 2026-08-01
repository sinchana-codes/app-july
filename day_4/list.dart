void main() {

    List<String> users = ["omkar","krithik","dev"];
    print(users);

    //access the data through index number
    //listname[indexNO]

    print(users[0]);
    print(users[2]);



    //add the data - listName.add(value)
    users.add("poorna");

    print(users);


    //remove the data - listname.remove(value)
    users.remove("omkar");

    print(users);



    //total number of data
    print(users.length);



}