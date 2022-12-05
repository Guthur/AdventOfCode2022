:- set_prolog_flag(double_quotes, chars).

% Advent of Code 2022 Day 3 Puzzle
% https://adventofcode.com/2022/day/3

% relate character C1 by  code offset to character C2
char_offset_char(C1, O, C2) :-
    char_code(C1, C1c),
    Nc is C1c + O,
    char_code(C2, Nc).

% relate alpha base character `a`;`A` to 26 character sequence
alphabase_seq('a', Cs) :-
    alphabase_seq_('a', Cs).
alphabase_seq('A', Cs) :-
    alphabase_seq_('A', Cs).

alphabase_seq_(Base, Cs) :-
    findall(N, between(0, 25, N), Ns),
    maplist(char_offset_char(Base), Ns, Cs).

% assert DCG compatible terminal to parse item alpha code to priority
assert_item(ItemChar, Priority) :-
    assertz(item(Priority, [ItemChar|Rst], Rst)).

% assert all DCG compatible terminals for item codes.
assert_items :-
    alphabase_seq('a', Ls),
    alphabase_seq('A', Us),
    append(Ls, Us, ItemChars),
    length(ItemChars, L),
    findall(N, between(1, L, N), Priorities),
    maplist(assert_item, ItemChars, Priorities).

:- assert_items.

% parse sequence of rucksacks
rucksacks([R]) --> rucksack(R).
rucksacks([R|Rs]) --> rucksack(R), separator, rucksacks(Rs).
separator --> ['\n'].

% parse a rucksack of two equal length compartment
rucksack(C1-C2) -->
    compartment(C1),
    compartment(C2),
    {
        length(C1, L),
        length(C2, L)
    }.
% parse compartment of items
compartment([I]) --> item(I).
compartment([I|Is]) --> item(I), compartment(Is).

% relate a rucksack to it's matching priority across both
% compartments. Forms the logic for part 1 of puzzle.
rucksack_priority(R, P) :-
    R = C1-C2,
    member(P, C1),
    member(P, C2).

% relates rucksacks to part 1 solution
rucksacks_solution1(Rucksacks, Solution) :-
    maplist(rucksack_priority, Rucksacks, Priorities),
    sum_list(Priorities, Solution).

% Parse rucksacks in to groups
group([M1, M2, M3]) --> [M1, M2, M3].
group([M1, M2]) --> [M1, M2].
group([M1]) --> [M1].

groups([G]) --> group(G).
groups([G|Gs]) --> group(G), groups(Gs).

compartments_list(C1-C2, L) :- append(C1, C2, L).
group_badge(Group, Badge) :-
    maplist(compartments_list, Group, Ls),
    maplist(member(Badge), Ls).

% relate rucksacks to part 2 solution
rucksacks_solution2(Rucksacks, Solution) :-
    phrase(groups(Gs), Rucksacks),
    maplist(group_badge, Gs, Badges),
    sum_list(Badges, Solution).

% relate sequence of characters representing the state of rucksack
% to solutions for part 1 and 2 of puzzle
input_solution(Input, Solution1-Solution2) :-
    phrase(rucksacks(Rucksacks), Input),
    rucksacks_solution1(Rucksacks, Solution1),
    rucksacks_solution2(Rucksacks, Solution2).

% Example Input
input("vJrwpWtwJgWrhcsFMMfFFhFp\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\nPmmdzqPrVvPwwTWBwg\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\nttgJtRGJQctTZtZT\nCrZsJsPPZsGzwwsLwLmpwMDw").
