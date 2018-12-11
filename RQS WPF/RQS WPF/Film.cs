using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace RQS_WPF
{
    [DataContract]
    internal class Film
    {
        [DataMember]
        internal int id;
        [DataMember]
        internal String title;
        [DataMember]
        internal String original_title;
        [DataMember]
        internal String release_date;
        [DataMember]
        internal float vote_average;
        [DataMember]
        internal int vote_count;
        [DataMember]
        internal int runtime;
        [DataMember]
        internal List<Genre> genres;
        [DataMember]
        internal List<Acteur> acteurs;
        [DataMember]
        internal List<Realisateur> realisateurs;
        [DataMember]
        internal List<Certification> certifications;
        [DataMember]
        internal List<Status> status;
        [DataMember]
        internal byte[] poster;

        public Film(int id, string title, string original_title, string release_date, float vote_average, int vote_count, int runtime, List<Genre> genres, List<Acteur> acteurs, List<Realisateur> realisateurs, List<Certification> certifications, List<Status> status, byte[] poster)
        {
            this.id = id;
            this.title = title;
            this.original_title = original_title;
            this.release_date = release_date;
            this.vote_average = vote_average;
            this.vote_count = vote_count;
            this.runtime = runtime;
            this.genres = genres;
            this.acteurs = acteurs;
            this.realisateurs = realisateurs;
            this.certifications = certifications;
            this.status = status;
            this.poster = poster;
        }

        public override bool Equals(object obj)
        {
            return base.Equals(obj);
        }

        public override int GetHashCode()
        {
            return base.GetHashCode();
        }

        public override string ToString()
        {
            return id + " " + title + " " + original_title;
        }

        
    }
}
