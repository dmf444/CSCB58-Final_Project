# See note_maker named for length of notes. Otherwise, for actual notes, the
# default files in quartus only gives an octave: do, re, mi, fa, sol, la, ti, do.
# So apply numbers 1 -> 8, and that's your song.


def note_maker(step, time, note):
    note_lookup = {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 10}
    bin_len = to_bin(time)
    bin_note = to_bin(note_lookup[int(note)])
    return str(step) + ":TT=8'b" + bin_len + bin_note + ";"


def note_maker_named(step, time, note):
    # Valid Types:
    # q - Quarter Note, dq - Dotted Quarter
    # e - Eight Note, de - Dotted Eighth
    # s - Sixteenth note
    # h - Half Note
    # w - Whole Note
    named_producer = {'q': 1, "e": 8, "de": 9, "s": 15, "h": 2, "w": 4,
                      "dq": 3}
    note_lookup = {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 10}
    bin_len = to_bin(named_producer[time])
    bin_note = to_bin(note_lookup[int(note)])
    return str(step) + ":TT=8'b" + bin_len + bin_note + ";"


def to_bin(number):
    lookup_table = {0: "0000", 1: "0001", 2: "0010", 3: "0011", 4: "0100",
                    5: "0101", 6: "0110", 7: "0111", 8: "1000", 9: "1001",
                    10: "1010", 11: "1011", 12: "1100", 13: "1101",
                    14: "1110", 15: "1111"}
    return lookup_table[int(number)]

if(__name__ == "__main__"):
    store_list = []
    while True:
        type = input("NOTE_LEN input (Num/Name):")
        h = type.lower()
        if(h == "num" or h == "name"):
            break
    # This is the note generator
    store_list.append("0:TT=8'h1f;")
    if(type == "num"):
        loopers = input("NOTE_LEN NOTE:")
        while(loopers != "END"):
            nums = loopers.split(" ")
            try:
                n = note_maker(len(store_list), nums[0], nums[1])
                store_list.append(n)
            except Exception:
                print("MALFORMED INPUT. PLEASE RE-ENTER.")
            loopers = input("Number number:")
    else:
        loopers = input("NOTE_TYPE NOTE:")
        while(loopers != "END"):
            nums = loopers.split(" ")
            try:
                n = note_maker_named(len(store_list), nums[0], nums[1])
                store_list.append(n)
            except Exception:
                print("MALFORMED INPUT. PLEASE RE-ENTER.")
            loopers = input("Number number:")
    store_list.append(str(len(store_list)) + ":TT=8'h1f;")
    for i in store_list:
        print(i)
