#include <stdio.h>
#include <string.h>

// my structure, defining all of the required data
typedef struct
{
    char name[30];
    float servSize;
    int Calories;
    int Potassium;
    int Carb;
    int Sugars;
} Record;

// prototypes
int ReadFile(Record a[]);
void DisplayRecords(Record b[], int s[]);
int ChoiceMenu(Record c[], int s[]);
void SortRecords(Record d[], int s[]);
void SearchRecords(Record e[], int s[]);
int DeleteRecord(Record f[], int s[]);
int AddRecord(Record g[], int s[]);
int SaveRecords(Record h[], int s[]);
void SearchByName(Record i[], int s[]);
void SearchByCalories(Record j[], int s[]);
void SearchByCarbs(Record k[], int s[]);
void SearchBySugars(Record l[], int s[]);
void SortByAplhabet(Record p[], int s[]);
void SortBySugars(Record q[], int s[]);
void SortByCalories(Record r[], int s[]);

int main(void)
{
    // I chose 50 because it seems like a reasonable amount of entries
    Record food[50];
    int sort[50], i;

    // giving the sort index values
    for (i = 0; i < 50; i++)
    {
        sort[i] = i;
    }
    // my hort description of why I chose food
    printf("I chose to use foods and their calorie values because I enjoy "
           "learning about food science. and this is a representation of that. I "
           "also ask that you view the code in stacked mode so the formatting "
           "can be viewed properly instead of side by side");

    // calling on read and display functions
    ReadFile(food);
    DisplayRecords(food, sort);

    return 0;
}

// reads data from file
int ReadFile(Record a[])
{

    // declaring variables
    Record *ptr;
    FILE *ifile;
    char Filename[50], input, trash, empty[51] = {0};
    int i, flag, counter = 0, done = 0, j = 1;

    printf("\n\nWhat is the name of the file you would like to open??\n\n");
    do
    {
        // this is to make sure Filename is empty before testing its value
        strcpy(Filename, empty);

        // scanning until it reached a backspace
        scanf("%[^\n]", Filename);

        scanf("%c", &trash);
        if (strlen(Filename) > 50)
        {
            printf("Enter a file name under 50 characters\n");
        }

    } while (strlen(Filename) > 50);

    // if the value entered was a new line character and the file name is empty
    // then the user can choose the default value
    if ((trash == '\n' || trash == '\r') && strcmp(Filename, "") == 0)
    {
        strcpy(Filename, "mydata.txt");
    }
    // checks if the file exists
    if ((ifile = fopen(Filename, "r")) == NULL)
    {
        printf(
            "File does not exist, would you like to create a new one? \n[Y]/n\n");
        scanf("%c", &input);

        // for the different inputs
        switch (input)
        {
        case 'n':
            // more trash variable to make th \n character not mak the code act funny
            scanf("%c", &trash);
            ReadFile(a);
            return 0;
            break;
        case 'N':
            scanf("%c", &trash);
            ReadFile(a);
            return 0;
            break;
        default:
            // gets rid of new line characters so they dont affect the code
            if (input == '\r' || input == '\n')
                scanf("%c", &trash);

            // opens and closes the file for writing
            ifile = fopen(Filename, "w");
            fclose(ifile);

            // loop puts NULL in every space. for food name so that we can find the
            // end of th efile after it has been written over, and the ptr is usd so
            // that the value can be easily changed in the loop
            for (i = 0; i < 50; i++)
            {
                ptr = &a[i];
                strcpy(ptr->name, "NULL");
            }
        }
        return 0;
        // else statement for whe files dont come back as NULL
    }
    else
    {
        ifile = fopen(Filename, "r");

        ptr = &a[0];

        // scans the file line by line until it reaches the end
        while (!done)
        {
            fscanf(ifile, "%[^,] %c %f %c %d %c %d %c %d %c %d", ptr->name, &trash,
                   &ptr->servSize, &trash, &ptr->Calories, &trash, &ptr->Potassium,
                   &trash, &ptr->Carb, &trash, &ptr->Sugars);
            ptr++;
            counter++;
            flag = fscanf(ifile, "%d", &flag);
            if (flag == EOF)
                done = 1;
        }
        // this is so that the rest of the records in the file are stated as null
        for (i = counter; i < 50; i++)
        {
            ptr = &a[i];
            strcpy(ptr->name, "NULL");
        }
    }
    fclose(ifile);
    return (0);
}

// display menu function
void DisplayRecords(Record b[], int s[])
{
    int i, j, tag = 0;
    int h[50];

    // the header for the records
    printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
           "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
           "D. carbs (g)", "E. sugars (g)\n\n");

    // this is the loop for printing out the values of the records
    for (i = 0; i < 50; i++)
    {
        if (strcmp(b[s[i]].name, "NULL") != 0)
        {
            printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i - tag + 1,
                   b[s[i]].name, b[s[i]].servSize, b[s[i]].Calories,
                   b[s[i]].Potassium, b[s[i]].Carb, b[s[i]].Sugars);
        }
        else if (strcmp(b[s[i]].name, "NULL") == 0)
        {
            tag++;
        }
    }
    ChoiceMenu(b, s);
}

// where the user makes a choice
int ChoiceMenu(Record c[], int s[])
{
    // trash is for the trash variables
    char input, trash;

    // asks user for choice
    printf(
        "\nEnter an option\n\n[A.] Display all records\n B.  Sort records\n C.  "
        "Search for a record\n D.  Delete a record\n E.  Add a record\n S.  "
        "Save\n Q.  Quit\n ");
    scanf("%c", &input);

    // for all of my choices
    switch (input)
    {
    case 'A':
        scanf("%c", &trash);
        DisplayRecords(c, s);
        break;
    case 'a':
        scanf("%c", &trash);
        DisplayRecords(c, s);
        break;
    case 'B':
        scanf("%c", &trash);
        SortRecords(c, s);
        break;
    case 'b':
        scanf("%c", &trash);
        SortRecords(c, s);
        break;
    case 'C':
        scanf("%c", &trash);
        SearchRecords(c, s);
        break;
    case 'c':
        scanf("%c", &trash);
        SearchRecords(c, s);
        break;
    case 'D':
        scanf("%c", &trash);
        DeleteRecord(c, s);
        break;
    case 'd':
        scanf("%c", &trash);
        DeleteRecord(c, s);
        break;
    case 'E':
        scanf("%c", &trash);
        AddRecord(c, s);
        break;
    case 'e':
        scanf("%c", &trash);
        AddRecord(c, s);
        break;
    case 'S':
        scanf("%c", &trash);
        SaveRecords(c, s);
        break;
    case 's':
        scanf("%c", &trash);
        SaveRecords(c, s);
        break;
        // quits the function
    case 'Q':
        scanf("%c", &trash);
        return 0;
        break;
    case 'q':
        scanf("%c", &trash);
        return 0;
        break;
        // default function to take back to display records
    default:

        if (input != '\n' && input != '\r')
        {
            printf("Please Enter a valid input");
            scanf("%c", &trash);
        }
        DisplayRecords(c, s);
        break;
    }
    return 0;
}

// sorts the records alphabetically
void SortRecords(Record d[], int s[])
{
    char input, trash;

    // asks for user input
    printf("How would you like to sort the data?\n[A.] Alphabetically\n B.  "
           "Least to most Sugar\n C.  Least to most calories\n");
    scanf("%c", &input);

    // switch going through the different function calls
    switch (input)
    {
    case 'A':
        scanf("%c", &trash);
        SortByAplhabet(d, s);
        break;
    case 'a':
        scanf("%c", &trash);
        SortByAplhabet(d, s);
        break;
    case 'B':
        scanf("%c", &trash);
        SortBySugars(d, s);
        break;
    case 'b':
        scanf("%c", &trash);
        SortBySugars(d, s);
        break;
    case 'C':
        scanf("%c", &trash);
        SortByCalories(d, s);
        break;
    case 'c':
        scanf("%c", &trash);
        SortByCalories(d, s);
        break;
        // default gets rid of anything that isnt a new line, same as case 'A'
    default:
        if (trash != '\n' && trash != '\r')
            scanf("%c", &trash);
        SortByAplhabet(d, s);
        break;
    }
}

// calls on the SearchBy__ functions
void SearchRecords(Record e[], int s[])
{
    char trash, input;

    // asks for user input
    printf("\nWhat do you want to search? \n[A.] Food name \n B.  Calories \n C. "
           " Carbs \n D.  Sugars\n");
    scanf("%c", &input);

    // list of all choices
    switch (input)
    {
    case 'A':
        scanf("%c", &trash);
        SearchByName(e, s);
    case 'a':
        scanf("%c", &trash);
        SearchByName(e, s);
    case 'B':
        scanf("%c", &trash);
        SearchByCalories(e, s);
    case 'b':
        scanf("%c", &trash);
        SearchByCalories(e, s);
    case 'C':
        scanf("%c", &trash);
        SearchByCarbs(e, s);
    case 'c':
        scanf("%c", &trash);
        SearchByCarbs(e, s);
    case 'D':
        scanf("%c", &trash);
        SearchBySugars(e, s);
    case 'd':
        scanf("%c", &trash);
        SearchBySugars(e, s);
    default:
        // chooses the default value
        if (input != '\n' && input != '\r')
            scanf("%c", &trash);
        SearchByName(e, s);
    }
}

// deletes the added records
int DeleteRecord(Record f[], int s[])
{
    // declaring variables, including the array that needs to be deleted, the
    // empty function in cas something goes wrong and a reset is needed, a choice
    // to confirm, trash variable as usual, and index keeps trask of the index if
    // multiple records are deleted
    char DeleteArray[30], empty[31] = {0}, choice, trash;
    int input, i = 0, counter = 0, index[50] = {0};

    printf("Type the name of the fruit you want to delete: [Apple]\n");

    // asking for user input and tells the user if the input is too large
    do
    {
        strcpy(DeleteArray, empty);
        scanf("%[^\n]", DeleteArray);
        scanf("%c", &trash);
        // tells the user that the input is too large
        if (strlen(DeleteArray) > 30)
        {
            printf("Enter a name under 30 characters\n");
        }
    } while (strlen(DeleteArray) > 30);

    // default if user decides to use the name in parenthesis
    if ((trash == '\n' || trash == '\r') && strlen(DeleteArray) == 0)
    {
        strcpy(DeleteArray, "Apple");
    }

    // checks for all names that are equal to the name entered
    for (i = 0; i < 50; i++)
    {
        if (strcmp(f[s[i]].name, DeleteArray) == 0)
        {
            counter++;
        }
    }
    // tells the user if no values were found
    if (counter == 0 || strcmp(DeleteArray, "NULL") == 0)
    {
        printf("No foods were found with that name\n");
        DisplayRecords(f, s);
        return 0;
    }
    // asks the user to confirm
    printf("Are you sure you would like to delete %s??\n[N.] No\n Y.  Yes\n",
           DeleteArray);
    scanf("%c", &choice);

    // checks the input
    switch (choice)
    {
        // if 'Y' or 'y' the code will delete the input file
    case 'Y':
        // trashs the last thing entred so it doesnt affect the rest of the code
        scanf("%c", &trash);
        // initializing counter and i at 0
        counter = 0;
        i = 0;
        // checks if there were multiple records with the same name
        while (i < 50)
        {
            if (strcmp(DeleteArray, f[s[i]].name) == 0)
            {
                strcpy(f[s[i]].name, "NULL");
                index[s[i]] = 1;
                counter++;
            }
            i++;
        }
        // asks the user to confirm if there are multiple files
        if (counter > 1)
        {
            printf("\nThere were %d records with the name %s. please type the index "
                   "number of the file you would like to delete\n",
                   counter, DeleteArray);
        }
        // displays the index number for each file and the names
        for (i = 0; i < 50; i++)
        {
            if (index[s[i]] == 1)
            {
                printf("%d. %s", i + 1, DeleteArray);
            }
        }
        // takes input and makes sure it is valid
        do
        {
            scanf("%d", &input);
            if (input < 1 || input > 50 || index[s[input - 1]] == 0)
            {
                printf("Enter a valid input");
            }
        } while (input < 1 || input > 50 || index[s[input - 1]] == 0);

        // deletes only the one that the user chose and sets the others back to their origional name
        for (i = 0; i < 50; i++)
        {
            if (index[s[i]] == 1 && i != input - 1)
            {
                strcpy(f[s[i]].name, DeleteArray);
            }
        }
        // tells the user success and takes them back to the menu
        printf("Successfully deleted\n");
        scanf("%c", &trash);
        DisplayRecords(f, s);
        return 0;
        break;
        // same as other case but lowercase
    case 'y':
        scanf("%c", &trash);
        // setting variables to 0
        counter = 0;
        i = 0;
        // setting file names to null if they match
        while (i < 50)
        {
            if (strcmp(DeleteArray, f[s[i]].name) == 0)
            {
                strcpy(f[s[i]].name, "NULL");
                index[s[i]] = 1;
                counter++;
            }
            i++;
        }
        // informs the user of multiple entries with the same name
        if (counter > 1)
        {
            printf("\nThere were %d records with the name %s. please type the index "
                   "number of the file you would like to delete\n",
                   counter, DeleteArray);
        }
        // displays. the multiple entries and informs the user
        for (i = 0; i < 50; i++)
        {
            if (index[s[i]] == 1)
            {
                printf("%d. %s\n", i + 1, DeleteArray);
            }
        }
        // checks for value of input
        do
        {
            scanf("%d", &input);
            if (input < 1 || input > 50 || index[s[input - 1]] == 0)
            {
                printf("Enter a valid input");
            }
        } while (input < 1 || input > 50 || index[s[input - 1]] == 0);

        // deletes only the selected file
        for (i = 0; i < 50; i++)
        {
            if (index[s[i]] == 1 && i != input - 1)
            {
                strcpy(f[s[i]].name, DeleteArray);
            }
        }
        // informs the user of. success and goe sback to the display menu
        printf("Successfully deleted\n");
        DisplayRecords(f, s);
        return 0;
        break;
    // for anything besides Y/y
    default:
        // takes the user back to main menu
        if (choice != '\n' && choice != '\r')
            scanf("%c", &trash);
        DisplayRecords(f, s);
        return 0;
        break;
    }
}

// adds a record to the file
int AddRecord(Record g[], int s[])
{
    // declaring variables
    char NewName[30], empty[31] = {0}, trash;
    float NewServSize;
    int NewCals, NewPota, NewCarb, NewSugar, i, counter = 0;

    // loop testing if the file is already full or not
    for (i = 0; i < 50; i++)
    {
        if (strcmp(g[i].name, "NULL") == 0)
        {
            counter++;
        }
    }
    if (counter == 0)
    {
        printf("\nThe File is already full. please delete a file to add another "
               "one\n");
        DisplayRecords(g, s);
        return 0;
    }

    // asking for fruit name
    printf("enter the name of the fruit you want to add: [Apple]\n");
    do
    {
        // emptying fruit name
        strcpy(NewName, empty);
        scanf("%[^\n]", NewName);
        scanf("%c", &trash);
        // tests if value is too large
        if (strlen(NewName) > 30)
        {
            printf("\nenter a number under 30 characters\n");
        }
        if (strcmp(NewName, "NULL") == 0)
            printf("Please try again\n");
    } while (strlen(NewName) > 30 || strcmp(NewName, "NULL") == 0);

    if ((trash == '\n' || trash == '\r') && strlen(NewName) == 0)
    {
        strcpy(NewName, "Apple");
    }
    // part where we test ofr serving sizee and make sure it isnt a negative
    // variable
    printf("Enter the serving size (oz)\n");
    do
    {
        scanf("%f", &NewServSize);
        if (NewServSize < 0)
            printf("\nServing size can not be negative. try again\n");
    } while (NewServSize < 0);

    // same with serving size but in the calories section
    printf("Enter the number of calories\n");
    do
    {
        scanf("%d", &NewCals);
        if (NewCals < 0)
            printf("\nCalories can not be negative. try again\n");
    } while (NewCals < 0);

    // again same but potassium
    printf("Enter the amount of potassium (mg)\n");
    do
    {
        scanf("%d", &NewPota);
        if (NewPota < 0)
            printf("\nPotassium can not be negative. try again\n");
    } while (NewPota < 0);

    // repeat again
    printf("Enter the amount of carbs (g)\n");
    do
    {
        scanf("%d", &NewCarb);
        if (NewCarb < 0)
            printf("\nPotassium can not be negative. try again\n");
    } while (NewCarb < 0);

    // another repeat, all of the integers use the same function but just
    // different variable names
    printf("Enter the amount of sugar (g)\n");
    do
    {
        scanf("%d", &NewSugar);
        if (NewSugar < 0)
            printf("\nPotassium can not be negative. try again\n");
    } while (NewSugar < 0);

    // looks for the first null space
    for (i = 0; i < 50; i++)
    {
        if (strcmp(g[i].name, "NULL") == 0)
        {
            strcpy(g[i].name, NewName);
            g[i].servSize = NewServSize;
            g[i].Calories = NewCals;
            g[i].Carb = NewCarb;
            g[i].Potassium = NewPota;
            g[i].Sugars = NewSugar;
            // makes it so that i is larger than the loop allows so it will only rin
            // through this once
            i = 100;
        }
    }
    // trashes the next new line so it doesnt affect anything in the code
    scanf("%c", &trash);

    // tells the user that the record has been added and takes them back to the
    // main screen
    printf("Record Added :)\n\n");
    DisplayRecords(g, s);
    return 0;
}

// saves the list to a new file
int SaveRecords(Record h[], int s[])
{
    FILE *ifile;
    char FileName[75], empty[76] = {0}, trash, input;
    int i;

    // takes user input
    printf("What file name do you want to save the data to? [mydata.txt]\n");

    // tests for if a file name is under 75 characters
    do
    {
        strcpy(FileName, empty);
        scanf("%[^\n]", FileName);
        scanf("%c", &trash);
        if (strlen(FileName) > 75)
        {
            printf("Enter a file name under 75 characters");
        }
    } while (strlen(FileName) > 75);

    // tests if ther was no input from the user and does the default if theres
    // nothing
    if ((trash == '\n' || trash == '\r') && strcmp(FileName, "") == 0)
    {
        strcpy(FileName, "mydata.txt");
    }
    // tets if the file is NULL
    if ((ifile = fopen(FileName, "r")) != NULL)
    {
        printf("WARNING sis!! This file already exists and will be overwritten. "
               "Are you sure you want to save??\n[Y.] Yes\n N.  No\n");
        scanf("%c", &input);

        // tests user input
        switch (input)
        {
            // backs out of function
        case 'N':
            scanf("%c", &trash);
            DisplayRecords(h, s);
            return 0;
            break;
            // same as upper case
        case 'n':
            scanf("%c", &trash);
            DisplayRecords(h, s);
            return 0;
            break;
            // same as default
        case 'Y':
            scanf("%c", &trash);
            ifile = fopen(FileName, "w");

            for (i = 0; i < 50; i++)
            {
                if (strcmp(h[s[i]].name, "NULL") != 0)
                {
                    fprintf(ifile, "%s,%.1f,%d,%d,%d,%d\n", h[s[i]].name,
                            h[s[i]].servSize, h[s[i]].Calories, h[s[i]].Potassium,
                            h[s[i]].Carb, h[s[i]].Sugars);
                }
            }
            fclose(ifile);
            printf("\nFile saved girl boss! ;)\n");

            DisplayRecords(h, s);
            return 0;
            break;
            // same as uppercase
        case 'y':
            scanf("%c", &trash);
            ifile = fopen(FileName, "w");

            for (i = 0; i < 50; i++)
            {
                if (strcmp(h[s[i]].name, "NULL") != 0)
                {
                    fprintf(ifile, "%s,%.1f,%d,%d,%d,%d\n", h[s[i]].name,
                            h[s[i]].servSize, h[s[i]].Calories, h[s[i]].Potassium,
                            h[s[i]].Carb, h[s[i]].Sugars);
                }
            }
            fclose(ifile);
            printf("\nFile saved girl boss! ;)\n");

            DisplayRecords(h, s);
            return 0;
            break;
            // default function
        default:
            if (input != '\n' && input != '\r')
                scanf("%c", &trash);
            ifile = fopen(FileName, "w");

            for (i = 0; i < 50; i++)
            {
                if (strcmp(h[s[i]].name, "NULL") != 0)
                {
                    fprintf(ifile, "%s,%.1f,%d,%d,%d,%d\n", h[s[i]].name,
                            h[s[i]].servSize, h[s[i]].Calories, h[s[i]].Potassium,
                            h[s[i]].Carb, h[s[i]].Sugars);
                }
            }
            fclose(ifile);
            printf("\nFile saved girl boss! ;)\n");

            DisplayRecords(h, s);
            return 0;
            break;
        }
    }
    else
    {
        ifile = fopen(FileName, "w");
        for (i = 0; i < 50; i++)
        {
            if (strcmp(h[s[i]].name, "NULL") != 0)
            {
                fprintf(ifile, "%s,%.1f,%d,%d,%d,%d\n", h[s[i]].name, h[s[i]].servSize,
                        h[s[i]].Calories, h[s[i]].Potassium, h[s[i]].Carb,
                        h[s[i]].Sugars);
            }
        }
        fclose(ifile);
        printf("\nFile saved girl boss! ;)\n");

        DisplayRecords(h, s);
        return 0;
    }
}

// function for is user searches by name
void SearchByName(Record m[], int s[])
{
    char empty[100] = {0}, search[75], trash;
    int i, counter = 0;

    // Apples is the default
    printf("Enter a food to search for: [Apple]\n");
    do
    {
        strcpy(search, empty);
        scanf("%[^\n]", search);
        scanf("%c", &trash);
        // default search for apple
        if ((trash == '\n' || trash == '\r') && strlen(search) == 0)
        {
            strcpy(search, "Apple");
            printf("%s", search);
        }
        if (strlen(search) > 75)
            printf("Enter a name under 75 characters");
    } while (strlen(search) > 75);

    // header
    printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
           "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
           "D. carbs (g)", "E. sugars (g)\n\n");
    // tests all 50 available spaces in the array, and if they are the correct
    // value it will print them. this will be repeated for all of the search
    // functions
    for (i = 0; i < 50; i++)
    {
        if (strcmp(search, m[s[i]].name) == 0 && strcmp(search, "NULL") != 0)
        {
            printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                   m[s[i]].name, m[s[i]].servSize, m[s[i]].Calories,
                   m[s[i]].Potassium, m[s[i]].Carb, m[s[i]].Sugars);
            counter++;
        }
    }
    // if no records found it will display this, again will be repeated
    if (counter == 0)
        printf("No Food found :(");
    ChoiceMenu(m, s);
}

// searches by the number of cvalories and then asks above or below
void SearchByCalories(Record n[], int s[])
{
    int search, i, counter = 0;
    char input, trash;

    // asks foruser input and then asks above or below that value
    printf("Enter a Calorie number to search for: \n");
    //*c is so that it ignores the backspace character
    scanf("%d%*c", &search);
    printf("Would you like to search above or below this number?? \n[A.] Above\n "
           "B.  Below\n");
    scanf("%c", &input);

    // list of choices that test if a number is less than or greater than
    // depending on input
    switch (input)
    {
    case 'A':
        scanf("%c", &trash);
        // header
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // loop for all values
        for (i = 0; i < 50; i++)
        {
            if (n[s[i]].Calories >= search && strcmp(n[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       n[s[i]].name, n[s[i]].servSize, n[s[i]].Calories,
                       n[s[i]].Potassium, n[s[i]].Carb, n[s[i]].Sugars);
                counter++;
            }
        }
        // checking counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    // repetition of case 'A'
    case 'a':
        scanf("%c", &trash);

        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        for (i = 0; i < 50; i++)
        {
            if (n[s[i]].Calories >= search && strcmp(n[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       n[s[i]].name, n[s[i]].servSize, n[s[i]].Calories,
                       n[s[i]].Potassium, n[s[i]].Carb, n[s[i]].Sugars);
                counter++;
            }
        }
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
        // same as the before cases but not we test less than
    case 'B':
        scanf("%c", &trash);
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // for loop to test all values
        for (i = 0; i < 50; i++)
        {
            if (n[s[i]].Calories <= search && strcmp(n[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       n[s[i]].name, n[s[i]].servSize, n[s[i]].Calories,
                       n[s[i]].Potassium, n[s[i]].Carb, n[s[i]].Sugars);
                // counter to keep track
                counter++;
            }
        }
        // checks counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    // same as case 'B'
    case 'b':
        scanf("%c", &trash);
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        for (i = 0; i < 50; i++)
        {
            // still testing less than because it is 'b'
            if (n[s[i]].Calories <= search && strcmp(n[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       n[s[i]].name, n[s[i]].servSize, n[s[i]].Calories,
                       n[s[i]].Potassium, n[s[i]].Carb, n[s[i]].Sugars);
                counter++;
            }
        }
        // checks counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    // default case same as 'a' and 'A'
    default:
        // gets rid of whatever input was last so it doesnt interfere
        if (input != '\n' && input != '\r')
            scanf("%c", &trash);
        // header
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // loop to test all values
        for (i = 0; i < 50; i++)
        {
            // testing greater than
            if (n[s[i]].Calories >= search && strcmp(n[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       n[s[i]].name, n[s[i]].servSize, n[s[i]].Calories,
                       n[s[i]].Potassium, n[s[i]].Carb, n[s[i]].Sugars);
                // counter to see how many values were listed off
                counter++;
            }
        }
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    }
    // to take us back to choice menu
    ChoiceMenu(n, s);
}

// same as the search by calories function but. with carbs
void SearchByCarbs(Record o[], int s[])
{
    int search, i, counter = 0;
    char input, trash;

    // asks for user input
    printf("Enter a Carb number to search for: \n");
    // scans and deletes the backspace so it doesnt interfere
    scanf("%d%*c", &search);
    printf("Would you like to search above or below this number?? \n[A.] Above\n "
           "B.  Below\n");
    scanf("%c", &input);
    // list of choices that test if a number is less than or greater than
    // depending on input
    switch (input)
    {
    case 'A':
        scanf("%c", &trash);
        // header
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // loop to check all values
        for (i = 0; i < 50; i++)
        {
            // again repitition checking greater than values
            if (o[s[i]].Carb >= search && strcmp(o[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       o[s[i]].name, o[s[i]].servSize, o[s[i]].Calories,
                       o[s[i]].Potassium, o[s[i]].Carb, o[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counters value
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    // same as case 'A'
    case 'a':
        scanf("%c", &trash);

        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // loop to check all values of the array
        for (i = 0; i < 50; i++)
        {
            if (o[s[i]].Carb >= search && strcmp(o[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       o[s[i]].name, o[s[i]].servSize, o[s[i]].Calories,
                       o[s[i]].Potassium, o[s[i]].Carb, o[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
        // same as case 'A' but testing numbers less than
    case 'B':
        // trashinginput so that is doesnt interfere
        scanf("%c", &trash);
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // loop to check all values
        for (i = 0; i < 50; i++)
        {
            if (o[s[i]].Carb <= search && strcmp(o[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       o[s[i]].name, o[s[i]].servSize, o[s[i]].Calories,
                       o[s[i]].Potassium, o[s[i]].Carb, o[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    // same as case 'B' but lowercase
    case 'b':
        scanf("%c", &trash);
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // loop to check all vallues
        for (i = 0; i < 50; i++)
        {
            if (o[s[i]].Carb <= search && strcmp(o[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       o[s[i]].name, o[s[i]].servSize, o[s[i]].Calories,
                       o[s[i]].Potassium, o[s[i]].Carb, o[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    default:
        // default gets rid of input if it was anything besides enter
        if (input != '\n' && input != '\r')
            scanf("%c", &trash);

        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // for loop to check all values
        for (i = 0; i < 50; i++)
        {
            if (o[s[i]].Carb >= search && strcmp(o[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       o[s[i]].name, o[s[i]].servSize, o[s[i]].Calories,
                       o[s[i]].Potassium, o[s[i]].Carb, o[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check ounter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    }
    ChoiceMenu(o, s);
}

// again same thing as the other search. functions, just with the sugar values
void SearchBySugars(Record l[], int s[])
{
    int search, i, counter = 0;
    char input, trash;

    // asks for user input
    printf("Enter amount of sugar to search for: \n");
    // scans and deletes the backspace so it doesnt interfere
    scanf("%d%*c", &search);
    printf("Would you like to search above or below this number?? \n[A.] Above\n "
           "B.  Below\n");
    scanf("%c", &input);

    // list of choices that test if a number is less than or greater than
    // depending on input
    switch (input)
    {
    case 'A':
        scanf("%c", &trash);

        // header
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // for loop to check all values
        for (i = 0; i < 50; i++)
        {
            // geater than because checking above
            if (l[s[i]].Sugars >= search && strcmp(l[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       l[s[i]].name, l[s[i]].servSize, l[s[i]].Calories,
                       l[s[i]].Potassium, l[s[i]].Carb, l[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    // same as case 'A'. but lowercase
    case 'a':
        scanf("%c", &trash);

        // header
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // for loop to check all values
        for (i = 0; i < 50; i++)
        {
            if (l[s[i]].Sugars >= search && strcmp(l[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       l[s[i]].name, l[s[i]].servSize, l[s[i]].Calories,
                       l[s[i]].Potassium, l[s[i]].Carb, l[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
        // same as case 'A' but checks less than instead of greater than
    case 'B':
        scanf("%c", &trash);
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // for loop to check all values
        for (i = 0; i < 50; i++)
        {
            // less than instead of greater than
            if (l[s[i]].Sugars <= search && strcmp(l[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       l[s[i]].name, l[s[i]].servSize, l[s[i]].Calories,
                       l[s[i]].Potassium, l[s[i]].Carb, l[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
        // same as case 'B' but lowercase
    case 'b':
        scanf("%c", &trash);
        // header
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // for loop to check all values
        for (i = 0; i < 50; i++)
        {
            // less than instead of greater than
            if (l[s[i]].Sugars <= search && strcmp(l[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       l[s[i]].name, l[s[i]].servSize, l[s[i]].Calories,
                       l[s[i]].Potassium, l[s[i]].Carb, l[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    default:
        // gets rid of anything that could mess up the code for default
        if (input != '\n' && input != '\r')
            scanf("%c", &trash);
        // header
        printf("\n\n%11s %22s %12s %20s %15s %19s", "Food Name",
               "A. Serving Size (oz)", "B. Calories", "C. Potassium (mg)",
               "D. carbs (g)", "E. sugars (g)\n\n");
        // for loop to check all values
        for (i = 0; i < 50; i++)
        {
            // greater than because it is the same as 'A'
            if (l[s[i]].Sugars >= search && strcmp(l[s[i]].name, "NULL") != 0)
            {
                printf("%2d. %-17s %-17.1f %-17d %-17d %-17d %-16d\n", i + 1,
                       l[s[i]].name, l[s[i]].servSize, l[s[i]].Calories,
                       l[s[i]].Potassium, l[s[i]].Carb, l[s[i]].Sugars);
                // counter
                counter++;
            }
        }
        // check counter
        if (counter == 0)
            printf("No Food found in that range:(");
        break;
    }
    // to take the user back to the choice menu after the code has been run
    ChoiceMenu(l, s);
}

// sorts the values by their alphabetical order
void SortByAplhabet(Record p[], int s[])
{
    int flag[50], i, j, temp;

    // makes the sort array initialized in this functions
    for (i = 0; i < 50; i++)
    {
        s[i] = i;
        flag[i] = 0;
    }

    // loop to test for lowercase letters
    for (i = 0; i < 50; i++)
    {
        if (p[s[i]].name[0] >= 'a' && p[s[i]].name[0] <= 'z')
        {
            // to make it uppercase
            p[s[i]].name[0] -= 32;
            // takes note of which ones were changed
            flag[i] = 0;
        }
    }
    // bubble sort
    for (i = 0; i < 50; i++)
    {
        for (j = 0; j < 50; j++)
        {
            // comparing the names in alphabetical order
            if (strcmp(p[s[i]].name, p[s[i + 1]].name) > 0)
            {
                temp = s[i];
                s[i] = s[i + 1];
                s[i + 1] = temp;
            }
        }
    }
    // changing back to lowercase
    for (i = 0; i < 50; i++)
    {
        if (flag[s[i]] == 1)
            p[s[i]].name[0] += 32;
    }
    // displays the records in sorted form
    DisplayRecords(p, s);
}

// sorts from least to most sugars
void SortBySugars(Record q[], int s[])
{
    int i, j, temp;

    // setting sort function back to normal and making flag equal to 0
    for (i = 0; i < 50; i++)
    {
        s[i] = i;
    }

    // bubble sort comparing sugar values
    for (i = 0; i < 49; i++)
    {
        for (j = 0; j < 49; j++)
        {
            if (q[s[j]].Sugars > q[s[j + 1]].Sugars)
            {
                temp = s[j];
                s[j] = s[j + 1];
                s[j + 1] = temp;
            }
        }
    }
    // display the sorted records
    DisplayRecords(q, s);
}

// sorts from least to most calories
void SortByCalories(Record r[], int s[])
{
    int i, j, temp;

    // setting sort function back to normal and making flag equal to 0
    for (i = 0; i < 50; i++)
    {
        s[i] = i;
    }

    // bubble sort comparing calorie values
    for (i = 0; i < 49; i++)
    {
        for (j = 0; j < 49; j++)
        {
            if (r[s[j]].Calories > r[s[j + 1]].Calories)
            {
                temp = s[j];
                s[j] = s[j + 1];
                s[j + 1] = temp;
            }
        }
    }
    // display the sorted records
    DisplayRecords(r, s);
}