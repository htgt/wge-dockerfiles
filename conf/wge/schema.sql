--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.2
-- Dumped by pg_dump version 9.5.21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: crispr_insert_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crispr_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF ( NEW.SPECIES_ID = 1 ) THEN
        INSERT INTO crisprs_human VALUES (NEW.*);
    ELSIF ( NEW.SPECIES_ID = 2 ) THEN
        INSERT INTO crisprs_mouse VALUES (NEW.*);
    ELSIF ( NEW.SPECIES_ID = 4 ) THEN
        INSERT INTO crisprs_grch38 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Invalid species_id given to crispr_insert_trigger()';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: crispr_pairs_insert_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crispr_pairs_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.id = NEW.left_id || '_' || NEW.right_id;
    IF ( NEW.SPECIES_ID = 1 ) THEN
        INSERT INTO crispr_pairs_human VALUES (NEW.*);
    ELSIF ( NEW.SPECIES_ID = 2 ) THEN
        INSERT INTO crispr_pairs_mouse VALUES (NEW.*);
    ELSIF ( NEW.SPECIES_ID = 4 ) THEN
        INSERT INTO crispr_pairs_grch38 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Invalid species_id given to crispr_pairs_insert_trigger()';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: crispr_pairs_update_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crispr_pairs_update_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_modified = NOW();
    NEW.id = NEW.left_id || '_' || NEW.right_id;
    RETURN NEW;
END;
$$;


--
-- Name: distance(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.distance(target integer, chr_start integer, chr_end integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
DECLARE
    result integer;
BEGIN 

    IF target < chr_start THEN
        RETURN chr_start - target;
    ELSIF target > chr_end THEN
        RETURN target - chr_end;
    ELSE
        RETURN 0;
    END IF;
    RETURN result;
END;
$$;


--
-- Name: rev_comp(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rev_comp(seq character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    comp_seq VARCHAR := '';  -- the reverse complement sequence
    len INTEGER;                   -- the length of the sequence
BEGIN
    len := LENGTH(seq);
    LOOP
        comp_seq := comp_seq || TRANSLATE(SUBSTR(seq, len, 1), 'ATCG', 'TAGC');
        len := len - 1;
        EXIT WHEN (len < 0);
    END LOOP;
    RETURN comp_seq;
END;
$$;


--
-- Name: update_library_design_job_modified(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_library_design_job_modified() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.last_modified = now();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: assemblies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assemblies (
    id text NOT NULL,
    species_id text NOT NULL
);


--
-- Name: haplotype_bobin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.haplotype_bobin (
    id integer NOT NULL,
    chrom text NOT NULL,
    pos integer NOT NULL,
    ref text NOT NULL,
    alt text NOT NULL,
    qual numeric,
    filter text,
    genome_phasing text
);


--
-- Name: bob1_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bob1_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bob1_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bob1_id_seq OWNED BY public.haplotype_bobin.id;


--
-- Name: haplotype_thp1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.haplotype_thp1 (
    id integer NOT NULL,
    chrom text NOT NULL,
    pos integer NOT NULL,
    ref text NOT NULL,
    alt text NOT NULL,
    qual numeric,
    filter text,
    genome_phasing text
);


--
-- Name: bob2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bob2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bob2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bob2_id_seq OWNED BY public.haplotype_thp1.id;


--
-- Name: chromosomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chromosomes (
    id text NOT NULL,
    species_id text NOT NULL,
    name text NOT NULL
);


--
-- Name: chry_bobin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chry_bobin (
    id integer NOT NULL,
    chrom text NOT NULL,
    pos integer NOT NULL,
    ref text NOT NULL,
    alt text NOT NULL,
    qual numeric,
    filter text,
    genome_phasing text
);


--
-- Name: chry_bobin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chry_bobin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chry_bobin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chry_bobin_id_seq OWNED BY public.chry_bobin.id;


--
-- Name: chry_kolf2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chry_kolf2 (
    id integer NOT NULL,
    chrom text NOT NULL,
    pos integer NOT NULL,
    ref text NOT NULL,
    alt text NOT NULL,
    qual numeric,
    filter text,
    genomic_phasing text
);


--
-- Name: chry_thp1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chry_thp1 (
    id integer NOT NULL,
    chrom text NOT NULL,
    pos integer NOT NULL,
    ref text NOT NULL,
    alt text NOT NULL,
    qual numeric,
    filter text,
    genome_phasing text
);


--
-- Name: chry_thp1_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chry_thp1_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chry_thp1_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chry_thp1_id_seq OWNED BY public.chry_thp1.id;


--
-- Name: crispr_ots_pending; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crispr_ots_pending (
    crispr_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: crispr_pair_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crispr_pair_statuses (
    id integer NOT NULL,
    status text NOT NULL
);


--
-- Name: crispr_pairs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crispr_pairs (
    left_id integer NOT NULL,
    right_id integer NOT NULL,
    spacer integer NOT NULL,
    off_target_ids integer[],
    status_id integer DEFAULT 0,
    species_id integer NOT NULL,
    off_target_summary text,
    last_modified timestamp without time zone DEFAULT now(),
    id text NOT NULL
);


--
-- Name: crispr_pairs_grch38; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crispr_pairs_grch38 (
    CONSTRAINT crispr_pairs_grch38_species_id_check CHECK ((species_id = 4))
)
INHERITS (public.crispr_pairs);


--
-- Name: crispr_pairs_human; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crispr_pairs_human (
    CONSTRAINT crispr_pairs_human_species_id_check CHECK ((species_id = 1))
)
INHERITS (public.crispr_pairs);


--
-- Name: crispr_pairs_mouse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crispr_pairs_mouse (
    CONSTRAINT crispr_pairs_mouse_species_id_check CHECK ((species_id = 2))
)
INHERITS (public.crispr_pairs);


--
-- Name: crisprs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crisprs (
    id integer NOT NULL,
    chr_name text NOT NULL,
    chr_start integer NOT NULL,
    seq text NOT NULL,
    pam_right boolean NOT NULL,
    species_id integer NOT NULL,
    off_target_ids integer[],
    off_target_summary text,
    exonic boolean DEFAULT false NOT NULL,
    genic boolean DEFAULT false NOT NULL
);


--
-- Name: crisprs_grch38; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crisprs_grch38 (
    gpu_calc boolean,
    CONSTRAINT crisprs_grch38_species_id_check CHECK ((species_id = 4))
)
INHERITS (public.crisprs);


--
-- Name: crisprs_human; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crisprs_human (
    id integer,
    chr_name text,
    chr_start integer,
    seq text,
    pam_right boolean,
    species_id integer,
    off_target_ids integer[],
    off_target_summary text,
    CONSTRAINT crisprs_human_species_id_check CHECK ((species_id = 1))
)
INHERITS (public.crisprs);


--
-- Name: crisprs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crisprs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crisprs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crisprs_id_seq OWNED BY public.crisprs_human.id;


--
-- Name: crisprs_mouse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crisprs_mouse (
    CONSTRAINT crispr_pairs_mouse_species_id_check CHECK ((species_id = 2))
)
INHERITS (public.crisprs);


--
-- Name: design_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.design_attempts (
    id integer NOT NULL,
    design_parameters json,
    gene_id text,
    status text,
    fail json,
    error text,
    design_ids integer[],
    species_id text NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    comment text,
    candidate_oligos json,
    candidate_regions json
);


--
-- Name: design_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.design_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.design_attempts_id_seq OWNED BY public.design_attempts.id;


--
-- Name: design_comment_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.design_comment_categories (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: design_comment_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.design_comment_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_comment_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.design_comment_categories_id_seq OWNED BY public.design_comment_categories.id;


--
-- Name: design_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.design_comments (
    id integer NOT NULL,
    design_comment_category_id integer NOT NULL,
    design_id integer NOT NULL,
    comment_text text DEFAULT ''::text NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: design_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.design_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.design_comments_id_seq OWNED BY public.design_comments.id;


--
-- Name: design_oligo_loci; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.design_oligo_loci (
    design_oligo_id integer NOT NULL,
    assembly_id text NOT NULL,
    chr_id text NOT NULL,
    chr_start integer NOT NULL,
    chr_end integer NOT NULL,
    chr_strand integer NOT NULL,
    CONSTRAINT design_oligo_loci_check CHECK ((chr_start <= chr_end)),
    CONSTRAINT design_oligo_loci_chr_strand_check CHECK ((chr_strand = ANY (ARRAY[1, (-1)])))
);


--
-- Name: design_oligo_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.design_oligo_types (
    id text NOT NULL
);


--
-- Name: design_oligos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.design_oligos (
    id integer NOT NULL,
    design_id integer NOT NULL,
    design_oligo_type_id text NOT NULL,
    seq text NOT NULL
);


--
-- Name: design_oligos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.design_oligos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_oligos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.design_oligos_id_seq OWNED BY public.design_oligos.id;


--
-- Name: design_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.design_types (
    id text NOT NULL
);


--
-- Name: designs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.designs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: designs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.designs (
    id integer DEFAULT nextval('public.designs_id_seq'::regclass) NOT NULL,
    species_id text NOT NULL,
    name text,
    created_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    design_type_id text NOT NULL,
    phase integer,
    validated_by_annotation text NOT NULL,
    target_transcript text,
    design_parameters json,
    cassette_first boolean DEFAULT true NOT NULL,
    CONSTRAINT designs_phase_check CHECK ((phase = ANY (ARRAY[(-1), 0, 1, 2]))),
    CONSTRAINT designs_validated_by_annotation_check CHECK ((validated_by_annotation = ANY (ARRAY['yes'::text, 'no'::text, 'maybe'::text, 'not done'::text])))
);


--
-- Name: off_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.off_targets (
    seq_id bigint NOT NULL,
    summary text,
    off_targets integer[]
);


--
-- Name: sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sequences (
    crispr_id integer NOT NULL,
    seq_id bigint NOT NULL
);


--
-- Name: ensembl_bigbed; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ensembl_bigbed AS
 SELECT c.species_id,
    c.chr_name,
    c.chr_start,
    c.id,
    c.exonic,
        CASE
            WHEN (c.off_target_summary IS NOT NULL) THEN c.off_target_summary
            ELSE o.summary
        END AS off_target_summary,
        CASE
            WHEN (c.pam_right = false) THEN '-'::text
            ELSE '+'::text
        END AS strand
   FROM ((public.crisprs c
   LEFT JOIN public.sequences s ON ((c.id = s.crispr_id)))
   LEFT JOIN public.off_targets o ON ((o.seq_id = s.seq_id)));


--
-- Name: exons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exons (
    id integer NOT NULL,
    ensembl_exon_id text NOT NULL,
    gene_id integer NOT NULL,
    chr_start integer NOT NULL,
    chr_end integer NOT NULL,
    chr_name text NOT NULL,
    rank integer NOT NULL,
    strand integer,
    phase integer,
    end_phase integer
);


--
-- Name: exons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exons_id_seq OWNED BY public.exons.id;


--
-- Name: feature_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature_type (
    id text NOT NULL
);


--
-- Name: gene_design; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gene_design (
    gene_id text NOT NULL,
    design_id integer NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    gene_type_id text NOT NULL
);


--
-- Name: gene_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gene_set (
    id integer NOT NULL,
    name text NOT NULL,
    source text NOT NULL,
    species_id text NOT NULL
);


--
-- Name: gene_set_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gene_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gene_set_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gene_set_id_seq OWNED BY public.gene_set.id;


--
-- Name: genes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genes (
    id integer NOT NULL,
    species_id text NOT NULL,
    marker_symbol text NOT NULL,
    ensembl_gene_id text NOT NULL,
    chr_start integer NOT NULL,
    chr_end integer NOT NULL,
    chr_name text NOT NULL,
    strand integer NOT NULL,
    canonical_transcript text NOT NULL
);


--
-- Name: genes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genes_id_seq OWNED BY public.genes.id;


--
-- Name: geneset_refseq; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.geneset_refseq (
    id text NOT NULL,
    feature_type_id text NOT NULL,
    chr_name text NOT NULL,
    chr_start integer NOT NULL,
    chr_end integer NOT NULL,
    strand integer NOT NULL,
    rank integer NOT NULL,
    name text,
    parent_id text,
    gene_type text,
    gene_id text,
    transcript_id text,
    protein_id text,
    biotype text,
    description text
);


--
-- Name: genotyping_primer_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genotyping_primer_types (
    id text NOT NULL
);


--
-- Name: genotyping_primers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genotyping_primers (
    id integer NOT NULL,
    genotyping_primer_type_id text NOT NULL,
    design_id integer NOT NULL,
    seq text NOT NULL
);


--
-- Name: genotyping_primers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genotyping_primers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genotyping_primers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genotyping_primers_id_seq OWNED BY public.genotyping_primers.id;


--
-- Name: haplotype; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.haplotype (
    id integer NOT NULL,
    species_id text NOT NULL,
    name text NOT NULL,
    source text NOT NULL,
    restricted text[]
);


--
-- Name: haplotype_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.haplotype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: haplotype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.haplotype_id_seq OWNED BY public.haplotype.id;


--
-- Name: haplotype_kolf2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.haplotype_kolf2 (
    id integer NOT NULL,
    chrom text NOT NULL,
    pos integer NOT NULL,
    ref text NOT NULL,
    alt text NOT NULL,
    qual numeric,
    filter text,
    genome_phasing text
);


--
-- Name: kolf2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kolf2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kolf2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kolf2_id_seq OWNED BY public.haplotype_kolf2.id;


--
-- Name: library_design_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_design_jobs (
    id text NOT NULL,
    name text NOT NULL,
    params json NOT NULL,
    target_region_count integer NOT NULL,
    library_design_stage_id text,
    progress_percent integer NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    error text,
    warning text,
    results_file text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by_id integer NOT NULL,
    last_modified timestamp without time zone DEFAULT now() NOT NULL,
    info text,
    input_file text
);


--
-- Name: library_design_stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_design_stages (
    id text NOT NULL,
    description text NOT NULL,
    rank integer NOT NULL
);


--
-- Name: off_targets_grch38_ngg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.off_targets_grch38_ngg (
    seq_id bigint,
    summary text,
    off_targets integer[]
)
INHERITS (public.off_targets);


--
-- Name: sequences_grch38_ngg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sequences_grch38_ngg (
    crispr_id integer,
    seq_id bigint
)
INHERITS (public.sequences);


--
-- Name: sequences_mouse_ngg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sequences_mouse_ngg (
)
INHERITS (public.sequences);


--
-- Name: species; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.species (
    numerical_id integer NOT NULL,
    id text NOT NULL,
    display_name text NOT NULL,
    active boolean DEFAULT false NOT NULL,
    species_name text
);


--
-- Name: species_default_assembly; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.species_default_assembly (
    species_id text NOT NULL,
    assembly_id text NOT NULL
);


--
-- Name: species_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.species_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: species_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.species_id_seq OWNED BY public.species.numerical_id;


--
-- Name: user_crispr_pairs_grch38; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_crispr_pairs_grch38 (
    crispr_pair_id text NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_crispr_pairs_human; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_crispr_pairs_human (
    crispr_pair_id text NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_crispr_pairs_mouse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_crispr_pairs_mouse (
    crispr_pair_id text NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_crisprs_grch38; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_crisprs_grch38 (
    crispr_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_crisprs_human; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_crisprs_human (
    crispr_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_crisprs_mouse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_crisprs_mouse (
    crispr_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_haplotype; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_haplotype (
    user_id integer NOT NULL,
    haplotype_id integer NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name text NOT NULL,
    password text,
    library_jobs_restricted boolean DEFAULT true,
    CONSTRAINT users_name_check CHECK ((name <> ''::text))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: variant_call_format; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variant_call_format (
    id integer NOT NULL,
    chrom text NOT NULL,
    pos integer NOT NULL,
    vcf_id text,
    ref text NOT NULL,
    alt text,
    qual numeric,
    filter text,
    info text,
    format text,
    genome_phasing text
);


--
-- Name: variant_call_format_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.variant_call_format_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: variant_call_format_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.variant_call_format_id_seq OWNED BY public.variant_call_format.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chry_bobin ALTER COLUMN id SET DEFAULT nextval('public.chry_bobin_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chry_thp1 ALTER COLUMN id SET DEFAULT nextval('public.chry_thp1_id_seq'::regclass);


--
-- Name: status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_grch38 ALTER COLUMN status_id SET DEFAULT 0;


--
-- Name: last_modified; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_grch38 ALTER COLUMN last_modified SET DEFAULT now();


--
-- Name: status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_human ALTER COLUMN status_id SET DEFAULT 0;


--
-- Name: last_modified; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_human ALTER COLUMN last_modified SET DEFAULT now();


--
-- Name: status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_mouse ALTER COLUMN status_id SET DEFAULT 0;


--
-- Name: last_modified; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_mouse ALTER COLUMN last_modified SET DEFAULT now();


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs ALTER COLUMN id SET DEFAULT nextval('public.crisprs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_grch38 ALTER COLUMN id SET DEFAULT nextval('public.crisprs_id_seq'::regclass);


--
-- Name: exonic; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_grch38 ALTER COLUMN exonic SET DEFAULT false;


--
-- Name: genic; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_grch38 ALTER COLUMN genic SET DEFAULT false;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_human ALTER COLUMN id SET DEFAULT nextval('public.crisprs_id_seq'::regclass);


--
-- Name: exonic; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_human ALTER COLUMN exonic SET DEFAULT false;


--
-- Name: genic; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_human ALTER COLUMN genic SET DEFAULT false;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_mouse ALTER COLUMN id SET DEFAULT nextval('public.crisprs_id_seq'::regclass);


--
-- Name: exonic; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_mouse ALTER COLUMN exonic SET DEFAULT false;


--
-- Name: genic; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_mouse ALTER COLUMN genic SET DEFAULT false;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_attempts ALTER COLUMN id SET DEFAULT nextval('public.design_attempts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_comment_categories ALTER COLUMN id SET DEFAULT nextval('public.design_comment_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_comments ALTER COLUMN id SET DEFAULT nextval('public.design_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligos ALTER COLUMN id SET DEFAULT nextval('public.design_oligos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exons ALTER COLUMN id SET DEFAULT nextval('public.exons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gene_set ALTER COLUMN id SET DEFAULT nextval('public.gene_set_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genes ALTER COLUMN id SET DEFAULT nextval('public.genes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genotyping_primers ALTER COLUMN id SET DEFAULT nextval('public.genotyping_primers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype ALTER COLUMN id SET DEFAULT nextval('public.haplotype_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype_bobin ALTER COLUMN id SET DEFAULT nextval('public.bob1_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype_kolf2 ALTER COLUMN id SET DEFAULT nextval('public.kolf2_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype_thp1 ALTER COLUMN id SET DEFAULT nextval('public.bob2_id_seq'::regclass);


--
-- Name: numerical_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species ALTER COLUMN numerical_id SET DEFAULT nextval('public.species_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variant_call_format ALTER COLUMN id SET DEFAULT nextval('public.variant_call_format_id_seq'::regclass);


--
-- Name: assemblies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assemblies
    ADD CONSTRAINT assemblies_pkey PRIMARY KEY (id);


--
-- Name: bob1_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype_bobin
    ADD CONSTRAINT bob1_pkey PRIMARY KEY (id);


--
-- Name: bob2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype_thp1
    ADD CONSTRAINT bob2_pkey PRIMARY KEY (id);


--
-- Name: chromosomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chromosomes
    ADD CONSTRAINT chromosomes_pkey PRIMARY KEY (id);


--
-- Name: chry_bobin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chry_bobin
    ADD CONSTRAINT chry_bobin_pkey PRIMARY KEY (id);


--
-- Name: chry_thp1_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chry_thp1
    ADD CONSTRAINT chry_thp1_pkey PRIMARY KEY (id);


--
-- Name: crispr_ots_pending_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_ots_pending
    ADD CONSTRAINT crispr_ots_pending_pkey PRIMARY KEY (crispr_id);


--
-- Name: crispr_pair_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pair_statuses
    ADD CONSTRAINT crispr_pair_statuses_pkey PRIMARY KEY (id);


--
-- Name: crispr_pairs_grch38_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_grch38
    ADD CONSTRAINT crispr_pairs_grch38_pkey PRIMARY KEY (left_id, right_id);


--
-- Name: crispr_pairs_human_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_human
    ADD CONSTRAINT crispr_pairs_human_pkey PRIMARY KEY (left_id, right_id);


--
-- Name: crispr_pairs_mouse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_mouse
    ADD CONSTRAINT crispr_pairs_mouse_pkey PRIMARY KEY (left_id, right_id);


--
-- Name: crispr_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs
    ADD CONSTRAINT crispr_pairs_pkey PRIMARY KEY (left_id, right_id);


--
-- Name: crisprs_grch38_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_grch38
    ADD CONSTRAINT crisprs_grch38_pkey PRIMARY KEY (id);


--
-- Name: crisprs_grch38_unique_loci; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_grch38
    ADD CONSTRAINT crisprs_grch38_unique_loci UNIQUE (chr_start, chr_name, pam_right);


--
-- Name: crisprs_human_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_human
    ADD CONSTRAINT crisprs_human_pkey PRIMARY KEY (id);


--
-- Name: crisprs_human_unique_loci; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_human
    ADD CONSTRAINT crisprs_human_unique_loci UNIQUE (chr_start, chr_name, pam_right);


--
-- Name: crisprs_mouse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_mouse
    ADD CONSTRAINT crisprs_mouse_pkey PRIMARY KEY (id);


--
-- Name: crisprs_mouse_unique_loci; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs_mouse
    ADD CONSTRAINT crisprs_mouse_unique_loci UNIQUE (chr_start, chr_name, pam_right);


--
-- Name: crisprs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crisprs
    ADD CONSTRAINT crisprs_pkey PRIMARY KEY (id);


--
-- Name: design_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_attempts
    ADD CONSTRAINT design_attempts_pkey PRIMARY KEY (id);


--
-- Name: design_comment_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_comment_categories
    ADD CONSTRAINT design_comment_categories_name_key UNIQUE (name);


--
-- Name: design_comment_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_comment_categories
    ADD CONSTRAINT design_comment_categories_pkey PRIMARY KEY (id);


--
-- Name: design_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_comments
    ADD CONSTRAINT design_comments_pkey PRIMARY KEY (id);


--
-- Name: design_oligo_loci_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligo_loci
    ADD CONSTRAINT design_oligo_loci_pkey PRIMARY KEY (design_oligo_id, assembly_id);


--
-- Name: design_oligo_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligo_types
    ADD CONSTRAINT design_oligo_types_pkey PRIMARY KEY (id);


--
-- Name: design_oligos_design_id_design_oligo_type_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligos
    ADD CONSTRAINT design_oligos_design_id_design_oligo_type_id_key UNIQUE (design_id, design_oligo_type_id);


--
-- Name: design_oligos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligos
    ADD CONSTRAINT design_oligos_pkey PRIMARY KEY (id);


--
-- Name: design_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_types
    ADD CONSTRAINT design_types_pkey PRIMARY KEY (id);


--
-- Name: designs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.designs
    ADD CONSTRAINT designs_pkey PRIMARY KEY (id);


--
-- Name: exons_ensembl_exon_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exons
    ADD CONSTRAINT exons_ensembl_exon_id_key UNIQUE (ensembl_exon_id, gene_id);


--
-- Name: exons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exons
    ADD CONSTRAINT exons_pkey PRIMARY KEY (id);


--
-- Name: feature_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_type
    ADD CONSTRAINT feature_type_pkey PRIMARY KEY (id);


--
-- Name: gene_design_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gene_design
    ADD CONSTRAINT gene_design_pkey PRIMARY KEY (gene_id, design_id);


--
-- Name: gene_set_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gene_set
    ADD CONSTRAINT gene_set_name_key UNIQUE (name);


--
-- Name: gene_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gene_set
    ADD CONSTRAINT gene_set_pkey PRIMARY KEY (id);


--
-- Name: gene_set_source_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gene_set
    ADD CONSTRAINT gene_set_source_key UNIQUE (source);


--
-- Name: genes_ensembl_gene_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genes
    ADD CONSTRAINT genes_ensembl_gene_id_key UNIQUE (ensembl_gene_id, species_id);


--
-- Name: genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genes
    ADD CONSTRAINT genes_pkey PRIMARY KEY (id);


--
-- Name: genes_species_id_marker_symbol_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genes
    ADD CONSTRAINT genes_species_id_marker_symbol_key UNIQUE (species_id, marker_symbol);


--
-- Name: geneset_refseq_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geneset_refseq
    ADD CONSTRAINT geneset_refseq_pkey PRIMARY KEY (id);


--
-- Name: genotyping_primer_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genotyping_primer_types
    ADD CONSTRAINT genotyping_primer_types_pkey PRIMARY KEY (id);


--
-- Name: genotyping_primers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genotyping_primers
    ADD CONSTRAINT genotyping_primers_pkey PRIMARY KEY (id);


--
-- Name: haplotype_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype
    ADD CONSTRAINT haplotype_name_key UNIQUE (name);


--
-- Name: haplotype_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype
    ADD CONSTRAINT haplotype_pkey PRIMARY KEY (id);


--
-- Name: kolf2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype_kolf2
    ADD CONSTRAINT kolf2_pkey PRIMARY KEY (id);


--
-- Name: library_design_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_design_jobs
    ADD CONSTRAINT library_design_jobs_pkey PRIMARY KEY (id);


--
-- Name: library_design_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_design_stages
    ADD CONSTRAINT library_design_stages_pkey PRIMARY KEY (id);


--
-- Name: off_targets_grch38_ngg_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.off_targets_grch38_ngg
    ADD CONSTRAINT off_targets_grch38_ngg_pkey1 PRIMARY KEY (seq_id);


--
-- Name: off_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.off_targets
    ADD CONSTRAINT off_targets_pkey PRIMARY KEY (seq_id);


--
-- Name: sequences_grch38_ngg_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequences_grch38_ngg
    ADD CONSTRAINT sequences_grch38_ngg_pkey PRIMARY KEY (crispr_id);


--
-- Name: sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequences
    ADD CONSTRAINT sequences_pkey PRIMARY KEY (crispr_id);


--
-- Name: species_default_assembly_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_default_assembly
    ADD CONSTRAINT species_default_assembly_pkey PRIMARY KEY (species_id);


--
-- Name: species_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_pkey PRIMARY KEY (numerical_id);


--
-- Name: unique_grch38_pair_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_grch38
    ADD CONSTRAINT unique_grch38_pair_id UNIQUE (id);


--
-- Name: unique_human_pair_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_human
    ADD CONSTRAINT unique_human_pair_id UNIQUE (id);


--
-- Name: unique_mouse_pair_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_mouse
    ADD CONSTRAINT unique_mouse_pair_id UNIQUE (id);


--
-- Name: unique_pair_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs
    ADD CONSTRAINT unique_pair_id UNIQUE (id);


--
-- Name: unique_species; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT unique_species UNIQUE (id);


--
-- Name: user_crispr_pairs_grch38_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_grch38
    ADD CONSTRAINT user_crispr_pairs_grch38_pkey PRIMARY KEY (crispr_pair_id, user_id);


--
-- Name: user_crispr_pairs_human_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_human
    ADD CONSTRAINT user_crispr_pairs_human_pkey PRIMARY KEY (crispr_pair_id, user_id);


--
-- Name: user_crispr_pairs_mouse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_mouse
    ADD CONSTRAINT user_crispr_pairs_mouse_pkey PRIMARY KEY (crispr_pair_id, user_id);


--
-- Name: user_crisprs_grch38_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_grch38
    ADD CONSTRAINT user_crisprs_grch38_pkey PRIMARY KEY (crispr_id, user_id);


--
-- Name: user_crisprs_human_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_human
    ADD CONSTRAINT user_crisprs_human_pkey PRIMARY KEY (crispr_id, user_id);


--
-- Name: user_crisprs_mouse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_mouse
    ADD CONSTRAINT user_crisprs_mouse_pkey PRIMARY KEY (crispr_id, user_id);


--
-- Name: users_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_name_key UNIQUE (name);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: variant_call_format_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variant_call_format
    ADD CONSTRAINT variant_call_format_pkey PRIMARY KEY (id);


--
-- Name: bob1_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bob1_index ON public.haplotype_bobin USING btree (chrom, pos);


--
-- Name: bob2_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bob2_index ON public.haplotype_thp1 USING btree (chrom, pos);


--
-- Name: crisprs_grch38_seq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crisprs_grch38_seq ON public.crisprs_grch38 USING btree (seq);


--
-- Name: crisprs_human_seq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crisprs_human_seq ON public.crisprs_human USING btree (seq);


--
-- Name: geneset_refseq_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX geneset_refseq_index ON public.geneset_refseq USING btree (chr_name, chr_start, chr_end);


--
-- Name: idx_crisprs_grch38_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crisprs_grch38_id ON public.crispr_pairs_grch38 USING btree (id);


--
-- Name: idx_crisprs_grch38_loci; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crisprs_grch38_loci ON public.crisprs_grch38 USING btree (chr_name, chr_start);


--
-- Name: idx_crisprs_human_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crisprs_human_id ON public.crispr_pairs_human USING btree (id);


--
-- Name: idx_crisprs_human_loci; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crisprs_human_loci ON public.crisprs_human USING btree (chr_name, chr_start);


--
-- Name: idx_crisprs_mouse_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crisprs_mouse_id ON public.crispr_pairs_mouse USING btree (id);


--
-- Name: idx_crisprs_mouse_loci; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crisprs_mouse_loci ON public.crisprs_mouse USING btree (chr_name, chr_start);


--
-- Name: idx_exon_gene_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exon_gene_id ON public.exons USING btree (gene_id);


--
-- Name: idx_exon_loci; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exon_loci ON public.exons USING btree (chr_name, chr_start, chr_end);


--
-- Name: idx_gene_loci; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gene_loci ON public.genes USING btree (chr_name, chr_start, chr_end, species_id);


--
-- Name: kolf2_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX kolf2_index ON public.haplotype_kolf2 USING btree (chrom, pos);


--
-- Name: sequences_mouse_ngg_crispr_id_seq_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sequences_mouse_ngg_crispr_id_seq_id_idx ON public.sequences_mouse_ngg USING btree (crispr_id, seq_id);


--
-- Name: variant_call_format_chrom_pos_seq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX variant_call_format_chrom_pos_seq ON public.variant_call_format USING btree (chrom, pos);


--
-- Name: crispr_pairs_grch38_update_time; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER crispr_pairs_grch38_update_time BEFORE UPDATE ON public.crispr_pairs_grch38 FOR EACH ROW EXECUTE PROCEDURE public.crispr_pairs_update_trigger();


--
-- Name: crispr_pairs_human_update_time; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER crispr_pairs_human_update_time BEFORE UPDATE ON public.crispr_pairs_human FOR EACH ROW EXECUTE PROCEDURE public.crispr_pairs_update_trigger();


--
-- Name: crispr_pairs_mouse_update_time; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER crispr_pairs_mouse_update_time BEFORE UPDATE ON public.crispr_pairs_mouse FOR EACH ROW EXECUTE PROCEDURE public.crispr_pairs_update_trigger();


--
-- Name: crispr_pairs_update_time; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER crispr_pairs_update_time BEFORE UPDATE ON public.crispr_pairs FOR EACH ROW EXECUTE PROCEDURE public.crispr_pairs_update_trigger();


--
-- Name: insert_crispr_pairs_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_crispr_pairs_trigger BEFORE INSERT ON public.crispr_pairs FOR EACH ROW EXECUTE PROCEDURE public.crispr_pairs_insert_trigger();


--
-- Name: insert_crisprs_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_crisprs_trigger BEFORE INSERT ON public.crisprs FOR EACH ROW EXECUTE PROCEDURE public.crispr_insert_trigger();


--
-- Name: update_library_design_job; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_library_design_job BEFORE UPDATE ON public.library_design_jobs FOR EACH ROW EXECUTE PROCEDURE public.update_library_design_job_modified();


--
-- Name: assemblies_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assemblies
    ADD CONSTRAINT assemblies_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: chromosomes_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chromosomes
    ADD CONSTRAINT chromosomes_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: crispr_pairs_grch38_left_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_grch38
    ADD CONSTRAINT crispr_pairs_grch38_left_id_fkey FOREIGN KEY (left_id) REFERENCES public.crisprs_grch38(id);


--
-- Name: crispr_pairs_grch38_right_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_grch38
    ADD CONSTRAINT crispr_pairs_grch38_right_id_fkey FOREIGN KEY (right_id) REFERENCES public.crisprs_grch38(id);


--
-- Name: crispr_pairs_human_left_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_human
    ADD CONSTRAINT crispr_pairs_human_left_id_fkey FOREIGN KEY (left_id) REFERENCES public.crisprs_human(id);


--
-- Name: crispr_pairs_human_right_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_human
    ADD CONSTRAINT crispr_pairs_human_right_id_fkey FOREIGN KEY (right_id) REFERENCES public.crisprs_human(id);


--
-- Name: crispr_pairs_left_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs
    ADD CONSTRAINT crispr_pairs_left_id_fkey FOREIGN KEY (left_id) REFERENCES public.crisprs(id);


--
-- Name: crispr_pairs_mouse_left_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_mouse
    ADD CONSTRAINT crispr_pairs_mouse_left_id_fkey FOREIGN KEY (left_id) REFERENCES public.crisprs_mouse(id);


--
-- Name: crispr_pairs_mouse_right_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_mouse
    ADD CONSTRAINT crispr_pairs_mouse_right_id_fkey FOREIGN KEY (right_id) REFERENCES public.crisprs_mouse(id);


--
-- Name: crispr_pairs_right_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs
    ADD CONSTRAINT crispr_pairs_right_id_fkey FOREIGN KEY (right_id) REFERENCES public.crisprs(id);


--
-- Name: crispr_pairs_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs
    ADD CONSTRAINT crispr_pairs_status_fkey FOREIGN KEY (status_id) REFERENCES public.crispr_pair_statuses(id);


--
-- Name: crispr_pairs_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_mouse
    ADD CONSTRAINT crispr_pairs_status_fkey FOREIGN KEY (status_id) REFERENCES public.crispr_pair_statuses(id);


--
-- Name: crispr_pairs_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_human
    ADD CONSTRAINT crispr_pairs_status_fkey FOREIGN KEY (status_id) REFERENCES public.crispr_pair_statuses(id);


--
-- Name: crispr_pairs_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crispr_pairs_grch38
    ADD CONSTRAINT crispr_pairs_status_fkey FOREIGN KEY (status_id) REFERENCES public.crispr_pair_statuses(id);


--
-- Name: design_attempts_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_attempts
    ADD CONSTRAINT design_attempts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: design_attempts_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_attempts
    ADD CONSTRAINT design_attempts_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: design_comments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_comments
    ADD CONSTRAINT design_comments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: design_comments_design_comment_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_comments
    ADD CONSTRAINT design_comments_design_comment_category_id_fkey FOREIGN KEY (design_comment_category_id) REFERENCES public.design_comment_categories(id);


--
-- Name: design_comments_design_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_comments
    ADD CONSTRAINT design_comments_design_id_fkey FOREIGN KEY (design_id) REFERENCES public.designs(id);


--
-- Name: design_oligo_loci_assembly_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligo_loci
    ADD CONSTRAINT design_oligo_loci_assembly_id_fkey FOREIGN KEY (assembly_id) REFERENCES public.assemblies(id);


--
-- Name: design_oligo_loci_chr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligo_loci
    ADD CONSTRAINT design_oligo_loci_chr_id_fkey FOREIGN KEY (chr_id) REFERENCES public.chromosomes(id);


--
-- Name: design_oligo_loci_design_oligo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligo_loci
    ADD CONSTRAINT design_oligo_loci_design_oligo_id_fkey FOREIGN KEY (design_oligo_id) REFERENCES public.design_oligos(id);


--
-- Name: design_oligos_design_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligos
    ADD CONSTRAINT design_oligos_design_id_fkey FOREIGN KEY (design_id) REFERENCES public.designs(id);


--
-- Name: design_oligos_design_oligo_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_oligos
    ADD CONSTRAINT design_oligos_design_oligo_type_id_fkey FOREIGN KEY (design_oligo_type_id) REFERENCES public.design_oligo_types(id);


--
-- Name: designs_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.designs
    ADD CONSTRAINT designs_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: designs_design_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.designs
    ADD CONSTRAINT designs_design_type_id_fkey FOREIGN KEY (design_type_id) REFERENCES public.design_types(id);


--
-- Name: designs_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.designs
    ADD CONSTRAINT designs_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: exons_gene_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exons
    ADD CONSTRAINT exons_gene_id_fkey FOREIGN KEY (gene_id) REFERENCES public.genes(id) ON DELETE CASCADE;


--
-- Name: gene_design_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gene_design
    ADD CONSTRAINT gene_design_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: gene_design_design_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gene_design
    ADD CONSTRAINT gene_design_design_id_fkey FOREIGN KEY (design_id) REFERENCES public.designs(id);


--
-- Name: gene_set_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gene_set
    ADD CONSTRAINT gene_set_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: genes_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genes
    ADD CONSTRAINT genes_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: geneset_refseq_feature_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geneset_refseq
    ADD CONSTRAINT geneset_refseq_feature_type_id_fkey FOREIGN KEY (feature_type_id) REFERENCES public.feature_type(id);


--
-- Name: geneset_refseq_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geneset_refseq
    ADD CONSTRAINT geneset_refseq_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.geneset_refseq(id);


--
-- Name: genotyping_primers_design_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genotyping_primers
    ADD CONSTRAINT genotyping_primers_design_id_fkey FOREIGN KEY (design_id) REFERENCES public.designs(id);


--
-- Name: genotyping_primers_genotyping_primer_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genotyping_primers
    ADD CONSTRAINT genotyping_primers_genotyping_primer_type_id_fkey FOREIGN KEY (genotyping_primer_type_id) REFERENCES public.genotyping_primer_types(id);


--
-- Name: haplotype_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haplotype
    ADD CONSTRAINT haplotype_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: library_design_jobs_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_design_jobs
    ADD CONSTRAINT library_design_jobs_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: library_design_jobs_library_design_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_design_jobs
    ADD CONSTRAINT library_design_jobs_library_design_stage_id_fkey FOREIGN KEY (library_design_stage_id) REFERENCES public.library_design_stages(id);


--
-- Name: species_default_assembly_assembly_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_default_assembly
    ADD CONSTRAINT species_default_assembly_assembly_id_fkey FOREIGN KEY (assembly_id) REFERENCES public.assemblies(id);


--
-- Name: species_default_assembly_species_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_default_assembly
    ADD CONSTRAINT species_default_assembly_species_id_fkey FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: user_crispr_pairs_grch38_crispr_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_grch38
    ADD CONSTRAINT user_crispr_pairs_grch38_crispr_pair_id_fkey FOREIGN KEY (crispr_pair_id) REFERENCES public.crispr_pairs_grch38(id);


--
-- Name: user_crispr_pairs_grch38_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_grch38
    ADD CONSTRAINT user_crispr_pairs_grch38_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_crispr_pairs_human_crispr_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_human
    ADD CONSTRAINT user_crispr_pairs_human_crispr_pair_id_fkey FOREIGN KEY (crispr_pair_id) REFERENCES public.crispr_pairs_human(id);


--
-- Name: user_crispr_pairs_human_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_human
    ADD CONSTRAINT user_crispr_pairs_human_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_crispr_pairs_mouse_crispr_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_mouse
    ADD CONSTRAINT user_crispr_pairs_mouse_crispr_pair_id_fkey FOREIGN KEY (crispr_pair_id) REFERENCES public.crispr_pairs_mouse(id);


--
-- Name: user_crispr_pairs_mouse_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crispr_pairs_mouse
    ADD CONSTRAINT user_crispr_pairs_mouse_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_crisprs_grch38_crispr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_grch38
    ADD CONSTRAINT user_crisprs_grch38_crispr_id_fkey FOREIGN KEY (crispr_id) REFERENCES public.crisprs_grch38(id);


--
-- Name: user_crisprs_grch38_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_grch38
    ADD CONSTRAINT user_crisprs_grch38_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_crisprs_human_crispr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_human
    ADD CONSTRAINT user_crisprs_human_crispr_id_fkey FOREIGN KEY (crispr_id) REFERENCES public.crisprs_human(id);


--
-- Name: user_crisprs_human_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_human
    ADD CONSTRAINT user_crisprs_human_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_crisprs_mouse_crispr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_mouse
    ADD CONSTRAINT user_crisprs_mouse_crispr_id_fkey FOREIGN KEY (crispr_id) REFERENCES public.crisprs_mouse(id);


--
-- Name: user_crisprs_mouse_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_crisprs_mouse
    ADD CONSTRAINT user_crisprs_mouse_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_haplotype_haplotype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_haplotype
    ADD CONSTRAINT user_haplotype_haplotype_id_fkey FOREIGN KEY (haplotype_id) REFERENCES public.haplotype(id);


--
-- Name: user_haplotype_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_haplotype
    ADD CONSTRAINT user_haplotype_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.2
-- Dumped by pg_dump version 9.5.21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: species; Type: TABLE DATA; Schema: public; Owner: wge_admin
--

COPY public.species (numerical_id, id, display_name, active, species_name) FROM stdin;
4	Grch38	Human (GRCh38)	t	Human
2	Mouse	Mouse (GRCm38)	t	Mouse
3	Pig	Pig (Sscrofa10.2)	f	Pig
1	Human	Human (GRCh37)	f	\N
\.


--
-- Data for Name: assemblies; Type: TABLE DATA; Schema: public; Owner: wge_admin
--

COPY public.assemblies (id, species_id) FROM stdin;
GRCh37	Human
GRCm38	Mouse
GRCh38	Human
\.


--
-- Data for Name: chromosomes; Type: TABLE DATA; Schema: public; Owner: wge_admin
--

COPY public.chromosomes (id, species_id, name) FROM stdin;
1	Mouse	1
2	Mouse	2
3	Mouse	3
4	Mouse	4
5	Mouse	5
6	Mouse	6
7	Mouse	7
8	Mouse	8
9	Mouse	9
10	Mouse	10
11	Mouse	11
12	Mouse	12
13	Mouse	13
14	Mouse	14
15	Mouse	15
16	Mouse	16
17	Mouse	17
18	Mouse	18
19	Mouse	19
20	Mouse	X
21	Mouse	Y
22	Human	1
23	Human	2
24	Human	3
25	Human	4
26	Human	5
27	Human	6
28	Human	7
29	Human	8
30	Human	9
31	Human	10
32	Human	11
33	Human	12
34	Human	13
35	Human	14
36	Human	15
37	Human	16
38	Human	17
39	Human	18
40	Human	19
41	Human	20
42	Human	21
43	Human	22
44	Human	X
45	Human	Y
\.


--
-- Data for Name: species_default_assembly; Type: TABLE DATA; Schema: public; Owner: wge_admin
--

COPY public.species_default_assembly (species_id, assembly_id) FROM stdin;
Mouse	GRCm38
Grch38	GRCh38
Human	GRCh38
\.


--
-- Name: species_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wge_admin
--

SELECT pg_catalog.setval('public.species_id_seq', 4, true);


--
-- PostgreSQL database dump complete
--

