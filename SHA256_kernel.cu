%%cuda --name sha.cu
#include<bits/stdc++.h>
#include "openssl/sha.h"
using namespace std;

string to_hex(unsigned char s) {
    stringstream ss;
    ss << hex << (int) s;
    return ss.str();
}   

string sha256(string line) {    
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, line.c_str(), line.length());
    SHA256_Final(hash, &sha256);
    string output = ""; 
    for (int i=0;i<SHA256_DIGEST_LENGTH;i++){
        output += to_hex(hash[i]);
    }       
    return output;
}

int main() {
    // Time Start
    string result;
    auto start = chrono::steady_clock::now();
    result=sha256("sri");
    // Time End
    auto end = chrono::steady_clock::now();
    cout << "sri\t :"<< result << endl;
    cout << "Elapsed time in nanoseconds : "<< chrono::duration_cast<chrono::nanoseconds>(end - start).count()<< " ns" << endl;
    cout << "Elapsed time in microseconds : "<< chrono::duration_cast<chrono::microseconds>(end - start).count()<< " micros" << endl;
    return 0;
}
//sri	 :d5e96656c6f455d2b0d8da4930a4c744cd86b4e6d2915de179d1f92f49316a9
//Elapsed time in nanoseconds : 68980 ns
//Elapsed time in microseconds : 68 micros