package it.uniba.di.ia.ius.prologAPI;

import com.sun.xml.internal.bind.v2.TODO;
import jpl.*;

import java.io.File;
import java.util.*;

public class JPLInterface extends PrologInterface {

    public JPLInterface(int type) {
        super(type);
        self = this;
        switch (type) {
            case SWI:
                jpl.JPL.setNativeLibraryDir(SWI_LIB_PATH);
                break;
            case YAP:
                jpl.JPL.setNativeLibraryDir(YAP_LIB_PATH);
                break;
            default:
                break;
        }
        jpl.JPL.init();
    }

    @Override
    public void close() {
    }

    @Override
    public void consult(File file) {
        Term t = new Compound("consult", new Term[]{new Atom(file.getAbsolutePath())});
        Query query = new Query(t);
        query.hasSolution();
    }

    @Override
    public void asserta(String pred, List<String> args) {
        metaCommand("asserta", pred, args);
    }

    @Override
    public void assertz(String pred, List<String> args) {
        metaCommand("assertz", pred, args);
    }

    @Override
    public void retract(String pred, List<String> args) {
        metaCommand("retract", pred, args);
    }

    @Override
    public void retractAll(String pred, List<String> args) {
        metaCommand("retractall", pred, args);
    }

    private void metaCommand(String command, String pred, List<String> args) {
        Term toSend;
        if ((args == null) || (args.size() == 0))
            toSend = new Atom(pred);
        else {
            Term[] termArgs = new Term[args.size()];
            for (int i = 0; i < args.size(); i++) {
                termArgs[i] = Util.textToTerm(args.get(i));
            }
            toSend = new Compound(pred, termArgs);
        }
        Term t = new Compound(command, new Term[]{toSend});
        Query query = new Query(t);
        query.hasSolution();
    }

    @Override
    public boolean statisfied(String pred, List<String> args) {
        Term term;
        if ((args == null) || (args.size() == 0))
            term = new Atom(pred);
        else {
            Term[] termArgs = new Term[args.size()];
            for (int i = 0; i < args.size(); i++) {
                termArgs[i] = Util.textToTerm(args.get(i));
            }
            term = new Compound(pred, termArgs);
        }
        Query query = new Query(term);
        return query.hasSolution();
    }

    @Override
    public Map<String, String> oneSolution(String pred, List<String> args) throws NoVariableException {
        Map<String, String> map = new HashMap<>();
        List<String> vars = new ArrayList<>(args.size());
        Term term;
        if ((args == null) || (args.size() == 0))
//            term = new Atom(pred);
            throw new NoVariableException();
        else {
            Term[] termArgs = new Term[args.size()];
            for (int i = 0; i < args.size(); i++) {
                String arg = args.get(i);
                termArgs[i] = Util.textToTerm(arg);
                if (prologNamedVariable(arg)) {
                    vars.add(arg);
                }
            }
            if (vars.isEmpty())
                throw new NoVariableException();
            term = new Compound(pred, termArgs);
        }
        Query query = new Query(term);
        java.util.Hashtable<String, Term> ht = query.oneSolution();
        for (String var : vars)
            map.put(var, ht.get(var).toString());

        return map;
    }


    @Override
    public List<Map<String, String>> allSolutions(String pred, List<String> args) {

//         TODO allcomune(X)
//        String pred = "all" + pred;
        List<Map<String, String>> listMap = new ArrayList<>(10);
        List<String> vars = new ArrayList<>(args.size());
        Term term;
        if ((args == null) || (args.size() == 0))
            term = new Atom(pred);
        else {
            Term[] termArgs = new Term[args.size()];
            for (int i = 0; i < args.size(); i++) {
                String arg = args.get(i);
                termArgs[i] = Util.textToTerm(arg);
                if (prologNamedVariable(arg)) {
                    vars.add(arg);
                }
            }
            term = new Compound(pred, termArgs);
        }
        Query query = new Query(term);
        java.util.Hashtable<String, Term>[] hts = query.allSolutions();
        for (Hashtable<String, Term> ht : hts) {
            Map<String, String> map = new HashMap<>();
            for (String var : vars) {
                map.put(var, ht.get(var).toString());
            }
            listMap.add(map);
        }

        return listMap;
    }
}
