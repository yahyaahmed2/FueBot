--
-- PostgreSQL database dump
--

\restrict DBR6he4wnOoPaJT78W0RAHyveATrrabqKfOQWyBAndsNCVVtf8l5U6Ea19lBNzj

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-02-28 20:31:55

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4953 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 16466)
-- Name: chat_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_history (
    chat_id integer NOT NULL,
    student_id integer NOT NULL,
    user_message text NOT NULL,
    bot_response text,
    session_status character varying(50),
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.chat_history OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16465)
-- Name: chat_history_chat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_history_chat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_history_chat_id_seq OWNER TO postgres;

--
-- TOC entry 4954 (class 0 OID 0)
-- Dependencies: 226
-- Name: chat_history_chat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_history_chat_id_seq OWNED BY public.chat_history.chat_id;


--
-- TOC entry 224 (class 1259 OID 16433)
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    course_id integer NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    credits integer NOT NULL,
    instructor character varying(255),
    semester character varying(50),
    prerequisites text,
    CONSTRAINT course_credits_check CHECK ((credits > 0))
);


ALTER TABLE public.course OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16432)
-- Name: course_course_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_course_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_course_id_seq OWNER TO postgres;

--
-- TOC entry 4955 (class 0 OID 0)
-- Dependencies: 223
-- Name: course_course_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.course_course_id_seq OWNED BY public.course.course_id;


--
-- TOC entry 220 (class 1259 OID 16390)
-- Name: degree_requirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.degree_requirement (
    req_id integer NOT NULL,
    description text NOT NULL,
    major character varying(100) NOT NULL,
    type character varying(50) NOT NULL,
    credits_needed integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    effective_date date NOT NULL,
    CONSTRAINT degree_requirement_credits_needed_check CHECK ((credits_needed > 0))
);


ALTER TABLE public.degree_requirement OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16389)
-- Name: degree_requirement_req_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.degree_requirement_req_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.degree_requirement_req_id_seq OWNER TO postgres;

--
-- TOC entry 4956 (class 0 OID 0)
-- Dependencies: 219
-- Name: degree_requirement_req_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.degree_requirement_req_id_seq OWNED BY public.degree_requirement.req_id;


--
-- TOC entry 222 (class 1259 OID 16408)
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    student_id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    gpa numeric(3,2),
    major character varying(100) NOT NULL,
    req_id integer,
    CONSTRAINT student_gpa_check CHECK (((gpa >= (0)::numeric) AND (gpa <= 4.00)))
);


ALTER TABLE public.student OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16448)
-- Name: student_course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_course (
    student_id integer NOT NULL,
    course_id integer NOT NULL
);


ALTER TABLE public.student_course OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16407)
-- Name: student_student_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_student_id_seq OWNER TO postgres;

--
-- TOC entry 4957 (class 0 OID 0)
-- Dependencies: 221
-- Name: student_student_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_student_id_seq OWNED BY public.student.student_id;


--
-- TOC entry 4778 (class 2604 OID 16469)
-- Name: chat_history chat_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_history ALTER COLUMN chat_id SET DEFAULT nextval('public.chat_history_chat_id_seq'::regclass);


--
-- TOC entry 4777 (class 2604 OID 16436)
-- Name: course course_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course ALTER COLUMN course_id SET DEFAULT nextval('public.course_course_id_seq'::regclass);


--
-- TOC entry 4774 (class 2604 OID 16393)
-- Name: degree_requirement req_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.degree_requirement ALTER COLUMN req_id SET DEFAULT nextval('public.degree_requirement_req_id_seq'::regclass);


--
-- TOC entry 4776 (class 2604 OID 16411)
-- Name: student student_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student ALTER COLUMN student_id SET DEFAULT nextval('public.student_student_id_seq'::regclass);


--
-- TOC entry 4796 (class 2606 OID 16478)
-- Name: chat_history chat_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_history
    ADD CONSTRAINT chat_history_pkey PRIMARY KEY (chat_id);


--
-- TOC entry 4790 (class 2606 OID 16447)
-- Name: course course_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_code_key UNIQUE (code);


--
-- TOC entry 4792 (class 2606 OID 16445)
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (course_id);


--
-- TOC entry 4784 (class 2606 OID 16406)
-- Name: degree_requirement degree_requirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.degree_requirement
    ADD CONSTRAINT degree_requirement_pkey PRIMARY KEY (req_id);


--
-- TOC entry 4794 (class 2606 OID 16454)
-- Name: student_course student_course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_course
    ADD CONSTRAINT student_course_pkey PRIMARY KEY (student_id, course_id);


--
-- TOC entry 4786 (class 2606 OID 16424)
-- Name: student student_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_email_key UNIQUE (email);


--
-- TOC entry 4788 (class 2606 OID 16422)
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (student_id);


--
-- TOC entry 4800 (class 2606 OID 16479)
-- Name: chat_history chat_history_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_history
    ADD CONSTRAINT chat_history_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(student_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4798 (class 2606 OID 16460)
-- Name: student_course student_course_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_course
    ADD CONSTRAINT student_course_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.course(course_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4799 (class 2606 OID 16455)
-- Name: student_course student_course_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_course
    ADD CONSTRAINT student_course_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(student_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4797 (class 2606 OID 16425)
-- Name: student student_req_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_req_id_fkey FOREIGN KEY (req_id) REFERENCES public.degree_requirement(req_id) ON UPDATE CASCADE ON DELETE SET NULL;


-- Completed on 2026-02-28 20:31:55

--
-- PostgreSQL database dump complete
--

\unrestrict DBR6he4wnOoPaJT78W0RAHyveATrrabqKfOQWyBAndsNCVVtf8l5U6Ea19lBNzj

