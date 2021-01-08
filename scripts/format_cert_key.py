import sys

#Function that adds a new line character and trailing backslash except on the final line
def format_file(f):
    with open(f, 'r') as fd:
        lines = fd.read().splitlines()
        line_num = 0
        for i in lines:
            i = "\""+i+"\\n\""
            line_num = line_num + 1
            if(len(lines) == line_num):
                print(i)
            else:
                print(i+"\\")


#Main function. Execution starts here
if __name__ == '__main__':

    for arg in (sys.argv):
        if (arg.endswith(".crt") or arg.endswith(".pem") or arg.endswith(".key")):
            print("String format of",arg,"file:")
            format_file(arg)
            print("")
        else:
            if (arg.endswith(".py") == False):
                print("Pass file with extension (*.crt) (*.pem) or (*.key) only!")
            
    input()




