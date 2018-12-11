using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace RQS_WPF
{
    [DataContract]
    internal class SimpleFilm
    {
        [DataMember]
        internal String title;
        [DataMember]
        internal String original_title;
        [DataMember]
        internal String status;
        [DataMember]
        internal String release_date;

        public SimpleFilm(string title, string original_title, String status, string release_date)
        {
            this.title = title;
            this.original_title = original_title;
            this.status = status;
            this.release_date = release_date;
        }

        public override bool Equals(object obj)
        {
            var film = obj as SimpleFilm;
            return film != null &&
                   title == film.title &&
                   original_title == film.original_title &&
                   status == film.status &&
                   release_date == film.release_date;
        }

        public override int GetHashCode()
        {
            var hashCode = -142796546;
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(title);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(original_title);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(status);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(release_date);
            return hashCode;
        }

        public override string ToString()
        {
            return base.ToString();
        }
    }
}
