#include <iostream>
#include <string>
using namespace std;

void fun(string str, int num){
    int cpy = num-1;

    if(str == ""){
        while(cpy != 0){
            fun(to_string(num-cpy), cpy);
            cpy--;
        }
    } else{
        if (num == 0) return;
        cout << str << "*" << num << endl;
        while(cpy != 0){
            fun(str+"*"+to_string(num-cpy), cpy);
            cpy--;
        }
    }
}

int main(){
    int n;
    cin >> n;
    fun("", n);
}