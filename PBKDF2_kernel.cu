%%cuda --name pbkdf2_kernel.cu
#include<bits/stdc++.h>
#include <openssl/evp.h>
using namespace std;

#define KEY_LEN      64
#define KEK_KEY_LEN  20
#define ITERATION   4096 
int main()
{ 
    size_t i;
    unsigned char *out;
    const char pwd[] = "password";
    unsigned char salt_value[] = {'s','a','l','t'};
    out = (unsigned char *) malloc(sizeof(unsigned char) * KEK_KEY_LEN);
    
    auto start = chrono::steady_clock::now();
    int c=PKCS5_PBKDF2_HMAC_SHA1(pwd, strlen(pwd), salt_value, sizeof(salt_value), ITERATION,KEK_KEY_LEN, out);
    auto end = chrono::steady_clock::now();
    cout<<"Password : "<<pwd<<endl;
    cout<<"Iterations : "<<ITERATION<<endl;
    cout<<"Salt :"; for(i=0;i<sizeof(salt_value);i++) { printf("%02x", salt_value[i]); } cout<<endl;
    cout<<"Hash :"; for(i=0;i<KEK_KEY_LEN;i++) { printf("%02x", out[i]); } printf("\n");    
    cout << "Elapsed time in nanoseconds : "<< chrono::duration_cast<chrono::nanoseconds>(end - start).count()<< " ns" << endl;
    cout << "Elapsed time in microseconds : "<< chrono::duration_cast<chrono::microseconds>(end - start).count()<< " micros" << endl;
    return 0;
}

//Password : password
//Iterations : 4096
//Salt :73616c74
//Hash :4b007901b765489abead49d926f721d065a429c1
//Elapsed time in nanoseconds : 2006218 ns
//Elapsed time in microseconds : 2006 micros