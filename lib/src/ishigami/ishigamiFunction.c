/* compile with gcc ishigamiFunction.c ini.c -lm -o ishigamiFunction */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "ini.h"

typedef struct
{
    float a;
    float b;
    float x1;
    float x2;
    float x3;
} ishigamidata;

static int handler(void* user, const char* section, const char* name,
                   const char* value)
{
    ishigamidata* data = (ishigamidata*)user;

    #define MATCH(s, n) strcmp(section, s) == 0 && strcmp(name, n) == 0
    if (MATCH("parameters", "a")) {
        data->a = atof(value);
    } else if (MATCH("parameters", "b")) {
        data->b = atof(value);
	} else if (MATCH("inputs", "x1")) {
        data->x1 = atof(value);
    } else if (MATCH("inputs", "x2")) {
        data->x2 = atof(value);
	} else if (MATCH("inputs", "x3")) {
        data->x3 = atof(value);
    } else {
        return 0;  /* unknown section/name, error */
    }
    return 1;
}

int main(int argc, char* argv[])
{
    ishigamidata data;
	float out;
	
    if ( argc != 2 ) /* argc should be 2 for correct execution */
    {
        /* We print argv[0] assuming it is the program name */
        printf( "usage: %s filename\n", argv[0] );
		return 1;
    }
	
	
    if (ini_parse(argv[1], handler, &data) < 0) {
        printf("Can't load '%s'\n", argv[1]);
        return 1;
    }
    printf("data loaded from '%s': a=%f, b=%f, x1=%f, x2=%f, x3=%f\n",
        argv[1], data.a, data.b, data.x1, data.x2, data.x3);
		
	out = sin(data.x1) + data.a*pow(sin(data.x2),2) + data.b*pow(data.x3,4)*sin(data.x1);
	
	/* write the result */
	FILE *file = fopen( "result.out", "w" );	
	fprintf(file,"%s\n", "Result");
	fprintf(file,"%f\n", out);
	fclose(file);
	
    return 0;
}
