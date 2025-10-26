#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char done[5] = "DONE";
char done2[6] = "DONE\n";

struct group
{
    char name[65];
    int people;
    int score;

    struct group* next;
};

void freeList(struct group* start)
{
    while(start != NULL)
    {
        struct group* temp = start;
        start = start->next;
        free(temp);
    }
}

/*
@return > 0 means g2 -> g1
@return < 0 means g1 -> g2
*/
int compare(struct group* g1, struct group* g2)
{
    if(g1->people == 0 || g2->people == 0)
    {
        return 0;
    }
    int comp1 = (g1->score)/(g1->people);
    int comp2 = (g2->score)/(g2->people);
    if(comp1 != comp2) return comp2 - comp1;
    else return strcmp(g1->name, g2->name);
}

void print_teams(struct group* pointer)
{
    while(pointer != NULL)
    {
        if(pointer->people != 0) printf("%s %d\n", pointer->name, (pointer->score)/(pointer->people)); /*FLOATING POINT EXCEPTION, when dividing by 0*/
        pointer = pointer->next;
    }
}

struct group* insert_team(struct group* head, struct group* team)
{
    if(head == NULL)
    {
        head = team;
        return head;
    }
    else /*Put in correct location of LinkedList*/
    {
        if(compare(team, head) < 0) /*new_group before head*/
        {
            team->next = head;
            head = team;
            return head;
        }
        else
        {
            struct group* pointer = head;
            int sorted = 0;
            while(pointer->next != NULL)
            {
                if(compare(team, pointer->next) < 0) /*pointer -> new_group -> pointer.next*/
                {
                    team->next = pointer->next;
                    pointer->next = team;
                    return head;
                }
                pointer = pointer->next;
            }
            pointer->next = team; /*add new_group to the end, ONLY if not sorted*/
            return head;
        }
    }
}


int main(int argc, char *argv[])
{
    if(argc != 2) return 1;
    
    FILE* file = fopen(argv[1], "r");
    
    char line[65];

    struct group* head =  NULL;

    int total_people = 0;

    while(fgets(line, 65, file)) 
    {
        if(strcmp(line,done) == 0 || strcmp(line,done2) == 0) break;
        /*the variable line contains each line (either name, people, or score)*/
        
        struct group* new_group = (group*) malloc(sizeof(struct group));

        /*Remove \n from line*/
        char* pos;
        if ((pos=strchr(line, '\n')) != NULL) *pos = '\0';
        /**/
        strcpy(new_group->name, line);
        
        fgets(line, 65, file);
        new_group->people = atoi(line);
        total_people += new_group->people;

        fgets(line, 65, file);
        new_group->score = atoi(line);

        new_group->next = NULL;


        head = insert_team(head, new_group);

    }
    print_teams(head);
    printf("%d\n", total_people);


    fclose(file);
    freeList(head);

    return EXIT_SUCCESS;
}