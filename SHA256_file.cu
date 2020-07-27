%%cuda --name sha256_cpu.cu
#include <bits/stdc++.h>
#include <locale.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <cuda.h>
#include "openssl/sha.h"
#include <dirent.h>
#include <ctype.h>
using namespace std;

typedef unsigned char BYTE;             
typedef uint32_t  WORD;             
typedef struct JOB {
	BYTE * data;
	unsigned long long size;
	BYTE digest[64];
	char fname[128];
}JOB;
char * hash_to_string(BYTE * buff) {
    int k,i;
    char *res=(char *)malloc(70); 
	for (i = 0;i < 32; i++)	{
        sprintf(res + k, "%.2x", buff[i]);
        k=k+2;
	}
	res[64] = 0;
	return res;
}

void sha256(JOB ** jobs, int n) {    
    for(int i=0;i<n;i++){      
      unsigned char hash[SHA256_DIGEST_LENGTH];
      SHA256_CTX sha256;
      SHA256_Init(&sha256);
      SHA256_Update(&sha256, jobs[i]->data, jobs[i]->size);
      SHA256_Final(jobs[i]->digest, &sha256);  
    }
}

JOB * JOB_init(BYTE * data, long size, char * fname) {
    JOB * j;
    j = (JOB *)malloc(sizeof(JOB));
    j->data = (BYTE *)malloc(sizeof(BYTE)*size);
    j->data = data;
    j->size = size;
    for (int i = 0; i < 64; i++){
        j->digest[i] = 0xff;
    }
    strcpy(j->fname, fname);
    return j;
}

int main(int argc, char **argv) {
    auto start2 = chrono::steady_clock::now();

    setlocale(LC_ALL, "en_US.UTF-8");  
	int i = 0, n = 0;
	size_t len;
	unsigned long temp;
	char * a_file = 0, * line = 0;
	BYTE * buff;
	char option, index;
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
                    BYTE * buffer;
                    buffer = (BYTE *) malloc(sizeof(char)*(read));
                    for(int i=0;i<read-1;i++){
                    buffer[i]=line[i];
                }
                jobs[n++] = JOB_init(buffer,read-1,line);
            }
        }
	} 

    auto start = chrono::steady_clock::now();
    sha256(jobs,n); 
    auto end = chrono::steady_clock::now();
    auto end2 = chrono::steady_clock::now();

    cout << "Number of tasks : "<< n<< endl;
    cout << "Avrage time for one task : "<< chrono::duration_cast<chrono::nanoseconds>((end - start)/n).count()<< " ns" << endl;
    cout << "Elapsed time in nanoseconds : "<< chrono::duration_cast<chrono::nanoseconds>(end - start).count()<< " ns" << endl;
    cout << "Elapsed time in microseconds : "<< chrono::duration_cast<chrono::microseconds>(end - start).count()<< " micros" << endl;
    cout << "Avrage total time for one task : "<< chrono::duration_cast<chrono::nanoseconds>((end2 - start2)/n).count()<< " ns" << endl;
    cout << "Total time in nanoseconds : "<< chrono::duration_cast<chrono::nanoseconds>(end2 - start2).count()<< " ns" << endl;
    cout << "Total time in microseconds : "<< chrono::duration_cast<chrono::microseconds>(end2 - start2).count()<< " micros" << endl;

    FILE * fp2;
    FILE * fp3;
    fp2=fopen("result_sha256_cpu.txt","w");
    fp3=fopen("result_sha256_cpu_detail.txt","w");
    
    if(fp2){
        for(int i=0;i<n;i++){
            fprintf(fp2,"%s\n",hash_to_string(jobs[i]->digest));
        }
    }
	if(fp3){
        for(int i=0;i<n;i++){
            fprintf(fp3,"Data :- %s",jobs[i]->data);
            fprintf(fp3,"Hashing String :- %s",jobs[i]->digest);
            fprintf(fp3,"Hashing digest :- %s\n",hash_to_string(jobs[i]->digest));
            fprintf(fp3,"--------\n\n");
        }   
    }
	return 0;
}

/*
Number of tasks : 230450
Avrage time for one task : 245 ns
Elapsed time in nanoseconds : 56634567 ns
Elapsed time in microseconds : 56634 micros
Avrage total time for one task : 570 ns
Total time in nanoseconds : 131569122 ns
Total time in microseconds : 131569 micros
*/