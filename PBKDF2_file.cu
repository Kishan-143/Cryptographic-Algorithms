%%cuda --name pbkdf2_file.cu
#include <bits/stdc++.h>
#include <locale.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <cuda.h>
#include <dirent.h>
#include <ctype.h>
#include <openssl/evp.h>
using namespace std;

#define KEY_LEN      32
#define KEK_KEY_LEN  32
#define ITERATION   4096 

typedef struct JOB {
  char * data;
  unsigned char* salt_value;
  unsigned char* out;
}JOB;

void pbkdf2(JOB ** jobs, int n) {    
    for(int i=0;i<n;i++){      
        unsigned char s[]={'s','a','l','t'};
      int c=PKCS5_PBKDF2_HMAC_SHA1(jobs[i]->data, strlen(jobs[i]->data), s, 4, ITERATION,KEK_KEY_LEN, jobs[i]->out);
    }
}

JOB * JOB_init(char * data, long size, char *salt,long s2) {
    JOB * j;
    j = (JOB *)malloc(sizeof(JOB));
    j->data = (char *)malloc(sizeof(char)*size);
    for(int i=0;i<size;i++) j->data[i]=data[i];
    j->salt_value= (unsigned char *)malloc(sizeof(unsigned char)*(s2));
    for(int i=0;i<s2;i++){
        j->salt_value[i]=salt[i];
    }
    j->out = (unsigned char *) malloc(sizeof(unsigned char) * KEK_KEY_LEN);    
    return j;
}
int main(int argc, char **argv) {
    
    auto start2 = chrono::steady_clock::now();
    setlocale(LC_ALL, "en_US.UTF-8");  
  	
    int n=0;
    size_t len;
    char * a_file = 0, * line = 0;
    char *buff;
    ssize_t read;
    JOB ** jobs;
    
    a_file=argv[1];
	  if (a_file) {
    		FILE * f = 0;
        f = fopen(a_file, "r");
        if(f){
            for (n = 0; getline(&line, &len, f) != -1; n++){}
            jobs = (JOB **)malloc(sizeof(JOB *)*n);
            fseek(f, 0, SEEK_SET);
            n=0;
            while(read!=-1){
                read=getline(&line,&len,f);
                if(read==-1) continue;
                char * buffer;
                long s2=4;
                buffer = (char *) malloc(sizeof(char)*(read));
                for(int i=0;i<read-1;i++){
                    buffer[i]=line[i];
                }
                jobs[n++] = JOB_init(buffer,read-1,buffer,s2);
            }
        }
	  }   

    auto start = chrono::steady_clock::now();
    pbkdf2(jobs,n);
    auto end = chrono::steady_clock::now();
    auto end2 = chrono::steady_clock::now();

    cout << "Number of tasks : "<< n<< endl;
    cout << "Avrage time for one task : "<< chrono::duration_cast<chrono::microseconds>((end - start)/n).count()<< " ms" << endl;
    cout << "Elapsed time in microseconds : "<< chrono::duration_cast<chrono::microseconds>(end - start).count()<< " micros" << endl;
    cout << "Avrage total time for one task : "<< chrono::duration_cast<chrono::nanoseconds>((end2 - start2)/n).count()<< " ns" << endl;
    cout << "Total time in microseconds : "<< chrono::duration_cast<chrono::microseconds>(end2 - start2).count()<< " micros" << endl;

    
    FILE * fp2;
    FILE * fp3;
    fp2=fopen("result_pbkdf2_cpu.txt","w");
    fp3=fopen("result_pbkdf2_cpu_detail.txt","w");
    
    if(fp2){  
        for(int j=0;j<n;j++){
           for(int i=0;i<KEK_KEY_LEN;i++) { fprintf(fp2,"%02x", jobs[j]->out[i]); }
           fprintf(fp2,"\n");     
        }
    }
	  if(fp3){
        for(int i=0;i<n;i++){
            fprintf(fp3,"Data :- %s",jobs[i]->data);
            fprintf(fp3,"len :- %d",strlen(jobs[i]->data));
            fprintf(fp3,"salt :- %s",jobs[i]->salt_value);
            fprintf(fp3,"--------\n\n");
        }   
    }
	return 0;
}
